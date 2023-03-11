//
//  Course.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation
#if canImport(CoreLocation)
    import CoreLocation
#endif

extension Sequence where Element == Distance {
    var median: Double {
        let v = Array(self).sorted()
        guard v.count > 0 else { return .defaultCourseLeg }
        let i = v.count / 2
        return v[i]
    }
}

// Any given course only uses a subset of these Distances,
// but storing all of them makes it easy to switch from one
// course layout to another.
public struct Distances: Codable, Sendable, Equatable {
    public var upwind: Distance = 200
    public var downwind: Distance = 200
    public var width: Distance = 200
    public var offset: Distance = 40
    public var gate: Distance = 40
    public var start: Distance = 100
    public var finish: Distance = 100
    public var finishLine: Distance = 40
    
    public subscript(key: DistanceMeasurement) -> Distance {
        get {
            switch key {
            case .upwind:
                return upwind
            case .downwind:
                return downwind
            case .width:
                return width
            case .offset:
                return offset
            case .gate:
                return gate
            case .start:
                return start
            case .finish:
                return finish
            case .finishLine:
                return finishLine
            }
        }
        set {
            switch key {
            case .upwind:
                upwind = newValue
            case .downwind:
                downwind = newValue
            case .width:
                width = newValue
            case .offset:
                offset = newValue
            case .gate:
                gate = newValue
            case .start:
                start = newValue
            case .finish:
                finish = newValue
            case .finishLine:
                finishLine = newValue
            }
        }
    }
}

/**
 The complete state information for a race course, including location of marks,
 target areas for marks, wind direction, and wind speed.
 */
public struct Course: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID = UUID()
    
    public var name: String = ""
    
    /// The location of the committee boat.
    public var startFlag = Coordinate(latitude: 41.777, longitude: -71.379)
    
    /// The location of the finish flag, if the finish boat has anchored.
    public var finishFlag: Coordinate? = nil
    
    public var windHistory: [WindInformation] = []
    public var windHalfLife: TimeInterval = 12.0 * 60.0
    
    /// The current orientation of the course in degrees from true north.
    public var courseDirection: Direction = 0.0
    
    /// Is the courseDirection locked independently of the windDirection?
    public var isCourseDirectionLocked: Bool = false
    
    /// The number of sailboats in the regatta, which indirectly determines
    /// the length of the start line.
    public var numberOfBoats: Int = 10
    
    public var boatLength: Distance = sunfishBoatLength
    
    /// The size of each target area on the chart
    public var targetRadius: Distance = 15.0
    
    public var distances = Distances()
    
    /// The coordinates of the physical marks on the course as recorded
    /// by the mark boat.
    public var marks: [Coordinate] = []
    
    public var weatherStationId: String = WeatherStation.providenceVisibility.id
    public var layoutId: UUID = Layout.triangle.id
    
    
    /// The length of a Sunfish sailboat in meters.
    public static let sunfishBoatLength: Distance = 4.19
    
    /// Creates a course with default settings for the Providence River
    /// near Edgewood Yacht Club.
    public init() {
    }
    
    public init(id: UUID, name: String = "", layoutID: UUID = Layout.triangle.id) {
        self.id = id
        self.name = name
        self.layoutId = layoutID
    }
    
    public init(id: String, name: String = "", layoutID: UUID = Layout.triangle.id) {
        self.id = UUID(uuidString: id)!
        self.name = name
        self.layoutId = layoutID
    }
    
    public var layout: Layout? {
        return layoutProvider.findLayout(id: layoutId)
    }
    
    /// The calculated length of the start line based on the number of boats.
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.sunfishBoatLength * 1.5
    }
    
    private func locateCenter<Loc: Location>(from here: Loc, using loci: [Locus]) -> Loc? {
        for locus in loci {
            let there = here.project(bearing: courseDirection + locus.bearing,
                                     distance: locus.distance.compute(course: self))
            if locus.isCourseCenter {
                return there
            }
            if let center = locateCenter(from: there, using: locus.loci) {
                return center
            }
        }
        return nil
    }
    
    /// The visual "center" of the race course. Wind arrows are drawn pointing toward
    /// this center. It is helpful if there is a mark target directly upwind of this center to
    /// make wind shifts easier to visualize.
    public var center: Coordinate {
        if let layout, let center = locateCenter(from: startFlag, using: layout.loci) {
            return center
        }
        return startFlag
    }
    
    public func forWeightedWindInformation(action: (WindInformation, Double) -> ()) {
        if windHalfLife <= 0.0 {
            guard let firstWindInfo = windHistory.first else { return }
            action(firstWindInfo, 1.0)
        }
        else {
            guard let mostRecentTime = windHistory.map({ $0.startTime }).max() else { return }
            for windInfo in windHistory {
                let weight = 1.0 / exp2(mostRecentTime.timeIntervalSince(windInfo.startTime) / windHalfLife)
                action(windInfo, weight)
            }
        }
    }
    
    /// Remove all marks from the course, including the finishFlag
    public mutating func pullAllMarks() {
        finishFlag = nil
        marks = []
    }
    
    /// Add a mark at the given coordinate
    public mutating func dropMark(at: Coordinate) {
        // Prevent duplicates, since they are pointless and confuse the SwifUI Map view.
        if !marks.contains(at) {
            marks.append(at)
        }
    }
    
    /// Remove the mark nearest to the given coordinate.
    public mutating func pullMark(near location: Coordinate) {
        switch marks.count {
        case 0:
            return
        case 1:
            marks = []
        default:
            var index = 0
            var d = location.distance(to: marks[0])
            for i in 1 ..< marks.count {
                let d2 = location.distance(to: marks[i])
                if d2 < d {
                    d = d2
                    index = i
                }
            }
            marks.remove(at: index)
        }
    }
    
    public mutating func updateWindHistory(_ info: WindInformation) {
        if let recent = windHistory.first {
            if info.startTime > recent.startTime {
                if windHistory.count >= 5 {
                    windHistory.removeLast()
                }
                windHistory.insert(info, at: 0)
            }
        }
        else {
            windHistory.append(info)
        }
    }
    
    /**
     Change the course to use the provided Layout.
     
     This updates the layoutId and ensures that the course distances
     match the ones in the layout.
     */
    public mutating func changeLayout(to layout: Layout) {
        layoutId = layout.id
    }
    
    public func targetCoordinate(target: MarkRole) -> Coordinate? {
        guard let layout else { return nil }
        var coord: Coordinate? = nil
        layout.positionTargets(for: self) { mark, location in
            if mark == target {
                coord = location
            }
        }
        return coord
    }
    
    public func positionTargets(action: (MarkRole, Coordinate) -> ()) {
        guard let layout = layout else { return }
        layout.loci.positionTargets(for: self, from: startFlag, action: action)
    }
    
    public func positionTargets(action: (MarkRole, Coordinate) async -> ()) async {
        guard let layout = layout else { return }
        await layout.loci.positionTargets(for: self, from: startFlag, action: action)
    }
    
    public func positionTargets<Loc: Location>(from startFlag: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) {
        guard let layout = layout else { return }
        layout.loci.positionTargets(for: self, from: startFlag, action: action, distances: distances)
    }
    
    public var targetMarks: [MarkRole] {
        guard let layout else { return [] }
        return layout.marks
    }
    
    /// Return the closest target to the markBoatLocation that doesn't have
    /// an existing mark within closeEnough of the target. Note that the finishFlag
    /// is excluded.
    public func nextTarget(from markBoatLocation: Coordinate, closeEnough: Distance, extraMark: Coordinate? = nil) -> MarkRole? {
        var nextTarget: MarkRole? = nil
        var nextMarkDistance = Distance.infinity
        
        var existingMarks = marks
        if let extraMark {
            existingMarks.append(extraMark)
        }
        
        positionTargets { target, targetLocation in
            if target.isMark && !marks.contains(where: { $0.distance(to: targetLocation) <= closeEnough}) {
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
        for mark in marks {
            let angle = startFlag.bearing(to: mark) - bearing
            let projectedDistance = origin.distance(to: mark) * cos(angle.degreesToRadians)
            if projectedDistance > maxDistance {
                maxDistance = projectedDistance
            }
        }
        positionTargets { target, location in
            let angle = startFlag.bearing(to: location) - bearing
            let projectedDistance = (origin.distance(to: location) * cos(angle.degreesToRadians)) + targetRadius
            if projectedDistance > maxDistance {
                maxDistance = projectedDistance
            }
        }
        return maxDistance
    }
    
    /// Returns the nearest target to a mark, as long as the mark is also the nearest
    /// mark to the target. Returns nil if there is no paired target.
    public func pairedTarget(for mark: Coordinate) -> MarkRole? {
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
        var nearestMark: Coordinate? = nil
        var nearestMarkDistance = Distance.infinity
        for m in marks {
            let d = nearestTargetLocation.distance(to: m)
            if d < nearestMarkDistance {
                nearestMark = m
                nearestMarkDistance = d
            }
        }
        if nearestMark == mark {
            return nearestTarget
        }
        return nil
    }
}

extension Course {
    public static let theFrozenFew = Course(id: "D4F19F6C-CCC4-4BB8-A376-368671E5C7ED",
                                            name: "The Frozen Few",
                                            layoutID: Layout.triangle.id)
    public static let optiGreenFleet = Course(id: "E3F4B122-F068-4FAB-9FDD-6996CC1938F6",
                                              name: "Opti green fleet",
                                              layoutID: Layout.windwardLeeward.id)
    public static let optiRedWhiteBlueFleet = Course(id: "8E5934D8-7EB4-4AA9-8ECD-8589C0F3ABB2",
                                                     name: "Opti RWB fleet",
                                                     layoutID: Layout.triangle.id)
    public static let brownTeamRacing = Course(id: "E953D6A3-85A5-4CFE-A0B9-43EC9B37AD6B",
                                               name: "Brown team racing",
                                               layoutID: Layout.digitalN.id)
    
    public static let all = [theFrozenFew, optiGreenFleet, optiRedWhiteBlueFleet, brownTeamRacing]
    
    public static let kitchenSink =
        Course(id: "307338F1-1354-4221-A617-872C26B05A40",
               name: "The Kitchen Sink")
}

extension Course {
    public init?(json: String) {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else { return nil }
        guard let c = try? decoder.decode(Course.self, from: data) else { return nil }
        self = c
    }
    
    public var jsonString: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}
