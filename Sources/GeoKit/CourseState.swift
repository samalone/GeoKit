//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/18/23.
//

import Foundation

/// CourseState combines a Course with wind history.
@dynamicMemberLookup
public struct CourseState: Codable, Sendable {
    public var course: Course
    public var windHistory: [WindInformation] = []

    public init(_ course: Course) {
        self.course = course
    }
    
    public var courseDirection: Direction {
        if let locked = course.lockedCourseDirection {
            return locked
        }
        else if let windDirection = windHistory.weightedAverageWindDirection(halfLife: course.windHalfLife) {
            return windDirection
        }
        return 0
    }
    
    /// Allow direct read-only access to Course properties without explicitly using
    /// our `current` property.
    public subscript<T>(dynamicMember keyPath: KeyPath<Course, T>) -> T {
        course[keyPath: keyPath]
    }
    
    public func forWeightedWindInformation(action: (WindInformation, Double) -> ()) {
        if course.windHalfLife <= 0.0 {
            guard let firstWindInfo = windHistory.first else { return }
            action(firstWindInfo, 1.0)
        }
        else {
            guard let mostRecentTime = windHistory.map({ $0.startTime }).max() else { return }
            for windInfo in windHistory {
                let weight = 1.0 / exp2(mostRecentTime.timeIntervalSince(windInfo.startTime) / course.windHalfLife)
                action(windInfo, weight)
            }
        }
    }
    
    private func locateCenter<Loc: Location>(from here: Loc, using loci: [Locus]) -> Loc? {
        for locus in loci {
            let there = here.project(bearing: courseDirection + locus.bearing,
                                     distance: locus.distance.compute(course: course))
            if locus.isCourseCenter {
                return there
            }
            if let center = locateCenter(from: there, using: locus.loci) {
                return center
            }
        }
        return nil
    }
    
    public func targetCoordinate(target: MarkRole) -> Coordinate? {
        var coord: Coordinate? = nil
        course.layout.loci.positionTargets(for: self, from: course.startFlag) { mark, location in
            if mark == target {
                coord = location
            }
        }
        return coord
    }
    
    public func positionTargets(action: (MarkRole, Coordinate) -> ()) {
        course.layout.loci.positionTargets(for: self, from: course.startFlag, action: action)
    }
    
    public func positionTargets(action: (MarkRole, Coordinate) async -> ()) async {
        await course.layout.loci.positionTargets(for: self, from: course.startFlag, action: action)
    }
    
    public func positionTargets<Loc: Location>(from startFlag: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) {
        course.layout.loci.positionTargets(for: self, from: startFlag, action: action, distances: distances)
    }
    
    /// The visual "center" of the race course. Wind arrows are drawn pointing toward
    /// this center. It is helpful if there is a mark target directly upwind of this center to
    /// make wind shifts easier to visualize.
    public var center: Coordinate {
        if let center = locateCenter(from: course.startFlag, using: course.layout.loci) {
            return center
        }
        return course.startFlag
    }
    
    /// Return the closest target to the markBoatLocation that doesn't have
    /// an existing mark within closeEnough of the target. Note that the finishFlag
    /// is excluded.
    public func nextTarget(from markBoatLocation: Coordinate, closeEnough: Distance, extraMark: Coordinate? = nil) -> MarkRole? {
        var nextTarget: MarkRole? = nil
        var nextMarkDistance = Distance.infinity
        
        var existingMarks = course.marks
        if let extraMark {
            existingMarks.append(extraMark)
        }
        
        positionTargets { target, targetLocation in
            if target.isMark && !course.marks.contains(where: { $0.distance(to: targetLocation) <= closeEnough}) {
                let d = markBoatLocation.distance(to: targetLocation)
                if d < nextMarkDistance {
                    nextTarget = target
                    nextMarkDistance = d
                }
            }
        }
        
        return nextTarget
    }
    
    /// The distance from the origin to the most distant mark
    /// or mark target in a particular direction. This is measured as a projected distance along the
    /// specified bearing. It is used to determine where to draw annotations on the chart so they
    /// don't overlap marks or targets.
    public func maximumProjectedDistance(from origin: Coordinate, bearing: Direction) -> Distance {
        var maxDistance: Distance = 0
        for mark in course.marks {
            let angle = course.startFlag.bearing(to: mark) - bearing
            let projectedDistance = origin.distance(to: mark) * cos(angle.degreesToRadians)
            if projectedDistance > maxDistance {
                maxDistance = projectedDistance
            }
        }
        positionTargets { target, location in
            let angle = course.startFlag.bearing(to: location) - bearing
            let projectedDistance = (origin.distance(to: location) * cos(angle.degreesToRadians)) + course.targetRadius
            if projectedDistance > maxDistance {
                maxDistance = projectedDistance
            }
        }
        return maxDistance
    }
    
    public func nearestTarget(to mark: Coordinate) -> TargetLocation? {
        var nearestTarget: MarkRole? = nil
        var nearestTargetLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var nearestTargetDistance = Distance.infinity
        positionTargets { role, location in
            if role.isMark {
                let d = mark.distance(to: location)
                if d < nearestTargetDistance {
                    nearestTarget = role
                    nearestTargetLocation = location
                    nearestTargetDistance = d
                }
            }
        }
        guard let nearestTarget else { return nil }
        return TargetLocation(role: nearestTarget, location: nearestTargetLocation)
    }
    
    /// Returns the nearest target to a mark, as long as the mark is also the nearest
    /// mark to the target. Returns nil if there is no paired target.
    public func currentRole(for mark: Coordinate) -> MarkRole {
        guard let nearestTarget = nearestTarget(to: mark) else { return .genericMark }
        guard let nearestMark = course.nearestMark(to: nearestTarget.location) else { return .genericMark }
        if nearestMark == mark {
            return nearestTarget.role
        }
        return .genericMark
    }
    
    /// Returns the mark currently filling the specified role, if there is one.
    public func markFilling(role: MarkRole) -> Coordinate? {
        guard let targetLocation = self.targetCoordinate(target: role) else { return nil }
        guard let nearestMark = course.nearestMark(to: targetLocation) else { return nil }
        if currentRole(for: nearestMark) == role {
            return nearestMark
        }
        return nil
    }
    
    public var enclosingRegion: CoordinateRegion {
        var rgn = CoordinateRegion.undefined
        rgn.enclose(course.startFlag)
        if let finishFlag = course.finishFlag {
            rgn.enclose(finishFlag)
        }
        
        positionTargets { target, location in
            let targetArea = CoordinateRegion(center: location,
                                              latitudinalMeters: course.targetRadius,
                                              longitudinalMeters: course.targetRadius)
            rgn.enclose(targetArea)
        }
        
        for mark in course.marks {
            rgn.enclose(mark)
        }

        return rgn
    }
}

extension CourseState: Identifiable {
    public var id: UUID {
        course.id
    }
}
