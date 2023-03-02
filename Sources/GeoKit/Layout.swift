//
//  Layout.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation
#if canImport(CoreLocation)
    import CoreLocation
#endif
#if canImport(CoreGraphics)
    import CoreGraphics
#endif

public enum DistanceMeasurement: String, Codable, Sendable {
    /// The distance of the upwind leg
    case upwind
    
    /// The distance fo the downwind leg
    case downwind
    
    /// The separation between the jibe mark(s) and the
    /// main upwind/downwind portion of the course
    case width
    
    /// The distance from a mark to its associated offset
    case offset
    
    /// The distance between marks in a gate
    case gate
    
    /// The distance from the start line to the main course
    case start
    
    /// This is the distance from the main course to the finish line
    case finish
    
    /// The length of the finish line
    case finishLine
}

public enum DistanceCalculation: Equatable, Codable {
    /**
     This distance is some multiple of the total lengths of the boats
     in the regatta.
     */
    case totalBoatLengths(times: Double)
    
    /**
     This distance is adjustable at race time by the race committee.
     If several distances share the same name, then the UI should
     display a single slider that adjusts all of the distances together.
     */
    case adjustable(measurement: DistanceMeasurement, times: Double = 1.0)
}

public enum CourseError: Error {
    case distanceNotFound
}

extension DistanceCalculation {
    func compute(course: Course) throws -> Distance {
        switch self {
        case .totalBoatLengths(let times):
            return times * Double(course.numberOfBoats) * course.boatLength
        case .adjustable(let measurement, let times):
            guard let distance = course.distances[measurement] else { throw CourseError.distanceNotFound }
            return distance * times
        }
    }
}


public enum MarkRole: Codable {
    /// The committee boat end of the start line, usually marked with an orange flag.
    case startFlag
    
    /// The pin end of the start line
    case startPin
    
    /// The committee boat end of the finish line, usually marked with a blue flag.
    case finishFlag
    
    /// The pin end of the finish line
    case finishPin
    
    case windward
    
    case windwardOffset
    
    case leeward
    
    case leewardOffset
    
    case leewardGateLeft
    case leewardGateRight
    
    case jibe
    
    case windwardJibe
    case leewardJibe
}

/**
 A Locus is an interesting point on the race course.
 Sometimes there will be a mark at the locus, but other times
 a locus is simply a reference point for other loci.
 
 The root locus for the course is the committee boat.
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
    
    /// A set of child loci that are placed relative to this locus
    public var loci: [Locus] = []
    
    public func positionTargets<Loc: Location>(for course: Course, from location: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())?) throws {
        let here = location.project(bearing: course.courseDirection + bearing,
                                    distance: try distance.compute(course: course))
        if let distances {
            distances(distance, location, here)
        }
        if let mark = mark {
            action(mark, here)
        }
        for locus in loci {
            try locus.positionTargets(for: course, from: here, action: action, distances: distances)
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
}

extension Array where Element == Locus {
    public func positionTargets<Loc: Location>(for course: Course, from signal: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) throws {
        for locus in self {
            try locus.positionTargets(for: course, from: signal, action: action, distances: distances)
        }
    }
}

/**
 The geometry of a race course, independent of its final position and dimensions.
 This specifies the placement of the marks relative to the committee boat
 and the wind direction.
 */
public struct Layout: Identifiable, Equatable, Codable {
    
    /// An immutable ID for this layout, stable even if its name changes.
    public var id: UUID
    
    /// A short name for the course layout, suitable for a UI picker.
    public var name: String
    
    /// A longer description of this course layout.
    public var description: String = ""
    
    /// The loci that are positioned relative to the committee boat.
    public var loci: [Locus]
    
    public init(id: UUID, name: String, description: String = "", loci: [Locus]) {
        self.id = id
        self.name = name
        self.description = description
        self.loci = loci
    }
    
    public func positionTargets(for course: Course, action: (MarkRole, Coordinate) -> ()) throws {
        try loci.positionTargets(for: course, from: course.signal, action: action)
    }
    
    public func positionTargets<Loc: Location>(for course: Course, from signal: Loc,
                                               action: (MarkRole, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) throws {
        try loci.positionTargets(for: course, from: signal, action: action, distances: distances)
    }
    
    public var distanceMeasurements: Set<DistanceMeasurement> {
        var names = Set<DistanceMeasurement>()
        for locus in loci {
            locus.forEachDistanceMeasurement { names.insert($0) }
        }
        return names
    }
    
    public static let triangle =
    Layout(id: UUID(uuidString: "EF24BF8B-E5B9-4E7A-9E47-46E8CED73E79")!,
           name: "Triangle",
           description: "A simple triangle course with a combined start/finish line in the middle of the course.",
           loci: [
            Locus(bearing: -90,
                  distance: .totalBoatLengths(times: 0.75),
                  loci: [
                    Locus(bearing: -90,
                          distance: .totalBoatLengths(times: 0.75),
                          mark: .startPin),
                    Locus(bearing: 0,
                          distance: .adjustable(measurement: .upwind),
                          mark: .windward),
                    Locus(bearing: -90,
                          distance: .adjustable(measurement: .width),
                          mark: .jibe),
                    Locus(bearing: 180,
                          distance: .adjustable(measurement: .downwind),
                          mark: .leeward),
                  ])
           ])
    
    public static let windwardLeeward =
    Layout(id: UUID(uuidString: "3538DD08-F2A2-489F-957F-FE429684CDD0")!,
           name: "Windward/Leeward",
           description: "A simple windward/leeward course with a combined start/finish line in the middle of the course.",
           loci: [
            Locus(bearing: -90,
                  distance: .totalBoatLengths(times: 0.75),
                  loci: [
                    Locus(bearing: -90,
                          distance: .totalBoatLengths(times: 0.75),
                          mark: .startPin),
                    Locus(bearing: 0,
                          distance: .adjustable(measurement: .upwind),
                          mark: .windward),
                    Locus(bearing: 180,
                          distance: .adjustable(measurement: .downwind),
                          mark: .leeward),
                  ])
           ])
    
    public static let digitalN =
    Layout(id: UUID(uuidString: "3BBDCF10-E106-402E-A236-E42F15BF858A")!,
           name: "Digital N",
           description: "An upwind/downwind course with offsets and a separate finish line, used for team racing.",
           loci: [
            Locus(bearing: -90,
                  distance: .totalBoatLengths(times: 0.75),
                  loci: [
                    Locus(bearing: -90,
                          distance: .totalBoatLengths(times: 0.75),
                          mark: .startPin),
                    Locus(bearing: 0,
                          distance: .adjustable(measurement: .start),
                          mark: .windward,
                          loci: [
                            Locus(bearing: 90,
                                  distance: .adjustable(measurement: .offset),
                                  mark: .windwardOffset,
                                  loci: [
                                    Locus(bearing: 180,
                                          distance: .adjustable(measurement: .downwind),
                                          mark: .leeward,
                                          loci: [
                                            Locus(bearing: 90,
                                                  distance: .adjustable(measurement: .offset),
                                                  mark: .leewardOffset,
                                                  loci: [
                                                    Locus(bearing: 0,
                                                          distance: .adjustable(measurement: .finish),
                                                          loci: [
                                                            Locus(bearing: 90,
                                                                  distance: .adjustable(measurement: .finishLine, times: 0.5),
                                                                  mark: .finishFlag),
                                                            Locus(bearing: -90,
                                                                  distance: .adjustable(measurement: .finishLine, times: 0.5),
                                                                  mark: .finishPin)
                                                          ])
                                                  ])
                                          ])
                                  ])
                          ])
                  ])
           ])
}
