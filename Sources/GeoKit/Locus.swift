//
//  Locus.swift
//  
//
//  Created by Stuart A. Malone on 3/16/23.
//

import Foundation

/**
 A Locus is an interesting point on the race course.
 Sometimes there will be a mark at the locus, but other times
 a locus is simply a reference point for other loci.
 
 The root locus for the course is the start flag. We assume that
 the committee boat anchors, sets the start flag, and the rest
 of the course is positioned relative to that.
 */
public struct Locus: Equatable, Codable {
    /// The bearing of this locus from its parent locus, measured as
    /// degrees from the wind direction (0 is windward, 90 is course right,
    /// -90 is course left, 180 is leeward).
    public var bearing: Direction = 0.0
    
    /// The distance of this locus from its parent locus, measured in
    /// meters. This distance is calculated at runtime from other course settings.
    public var distance: DistanceCalculation = .totalBoatLengths(times: 0.75)
    
    /// If there should be a mark at this locus, specifications for the mark.
    public var mark: MarkRole? = nil
    
    public var isCourseCenter: Bool = false
    
    /// A set of child loci that are placed relative to this locus
    public var loci: [Locus] = []
    
    public func positionTargets<Loc: Location>(for state: CourseState, from location: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())?) {
        let here = location.project(bearing: state.courseDirection + bearing,
                                    distance: distance.compute(course: state.course))
        if let distances {
            distances(distance, location, here)
        }
        if let mark = mark {
            action(mark, here)
        }
        for locus in loci {
            locus.positionTargets(for: state, from: here, action: action, distances: distances)
        }
    }
    
    public func positionTargets<Loc: Location>(for state: CourseState, from location: Loc,
                                               action: (MarkRole, Loc) async -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) async -> ())?) async {
        let here = location.project(bearing: state.courseDirection + bearing,
                                    distance: distance.compute(course: state.course))
        if let distances {
            await distances(distance, location, here)
        }
        if let mark = mark {
            await action(mark, here)
        }
        for locus in loci {
            await locus.positionTargets(for: state, from: here, action: action, distances: distances)
        }
    }
    
    public func forEachDistanceMeasurement(action: (DistanceMeasurement) -> ()) {
        switch distance {
        case .adjustable(let measurement, _):
            action(measurement)
        case .totalBoatLengths:
            break
        }
        for locus in loci {
            locus.forEachDistanceMeasurement(action: action)
        }
    }
    
    public func forEachMark(action: (MarkRole) -> ()) {
        if let mark {
            action(mark)
        }
        for locus in loci {
            locus.forEachMark(action: action)
        }
    }
}

extension Array where Element == Locus {
    public func positionTargets<Loc: Location>(for state: CourseState, from startFlag: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) {
        for locus in self {
            locus.positionTargets(for: state, from: startFlag, action: action, distances: distances)
        }
    }
    
    public func positionTargets<Loc: Location>(for state: CourseState, from startFlag: Loc,
                                               action: (MarkRole, Loc) async -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) async -> ())? = nil) async {
        for locus in self {
            await locus.positionTargets(for: state, from: startFlag, action: action, distances: distances)
        }
    }
    
    public func forEachMark(action: (MarkRole) -> ()) {
        for locus in self {
            locus.forEachMark(action: action)
        }
    }
}
