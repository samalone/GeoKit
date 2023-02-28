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
    case adjustable(name: String, times: Double = 1.0)
}

public enum CourseError: Error {
    case distanceNotFound
}

extension DistanceCalculation {
    func compute(course: Course) throws -> Distance {
        switch self {
        case .totalBoatLengths(let times):
            return times * Double(course.numberOfBoats) * course.boatLength
        case .adjustable(let name, let times):
            guard let distance = course.distances[name] else { throw CourseError.distanceNotFound }
            return distance * times
        }
    }
}

/**
 A MarkSpec is simply an identifier for a location on the course
 where the race committee should place a mark.
 */
public struct MarkSpec: Equatable, Codable {
    /// The name of the mark
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
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
    public var mark: MarkSpec? = nil
    
    /// A set of child loci that are placed relative to this locus
    public var loci: [Locus] = []
    
    public func positionTargets<Loc: Location>(for course: Course, from location: Loc,
                                               action: (MarkSpec, Loc) -> (),
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
    
    public func forEachDistanceName(action: (String) -> ()) {
        switch distance {
        case .adjustable(let name, _):
            action(name)
        case .totalBoatLengths:
            break
        }
        for locus in loci {
            locus.forEachDistanceName(action: action)
        }
    }
}

extension Array where Element == Locus {
    public func positionTargets<Loc: Location>(for course: Course, from signal: Loc,
                                               action: (MarkSpec, Loc) -> (),
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
    
    public func positionTargets(for course: Course, action: (MarkSpec, Coordinate) -> ()) throws {
        try loci.positionTargets(for: course, from: course.signal, action: action)
    }
    
    public func positionTargets<Loc: Location>(for course: Course, from signal: Loc,
                                               action: (MarkSpec, Loc) -> (),
                                               distances: ((DistanceCalculation, Loc, Loc) -> ())? = nil) throws {
        try loci.positionTargets(for: course, from: signal, action: action, distances: distances)
    }
    
    public var distanceNames: Set<String> {
        var names = Set<String>()
        for locus in loci {
            locus.forEachDistanceName { names.insert($0) }
        }
        return names
    }
    
    public static let triangle = Layout(id: UUID(uuidString: "EF24BF8B-E5B9-4E7A-9E47-46E8CED73E79")!,
                                        name: "Triangle",
                                        description: "A simple triangle course with a combined start/finish line in the middle of the course.",
                                        loci: [
                                            Locus(bearing: -90,
                                                  distance: .totalBoatLengths(times: 0.75),
                                                  loci: [
                                                    Locus(bearing: -90,
                                                          distance: .totalBoatLengths(times: 0.75),
                                                          mark: MarkSpec(name: "pin")),
                                                    Locus(bearing: 0,
                                                          distance: .adjustable(name: "wind"),
                                                          mark: MarkSpec(name: "wind")),
                                                    Locus(bearing: -90,
                                                          distance: .adjustable(name: "jibe"),
                                                          mark: MarkSpec(name: "jibe")),
                                                    Locus(bearing: 180,
                                                          distance: .adjustable(name: "lee"),
                                                          mark: MarkSpec(name: "lee")),
                                                  ])
                                        ])
    
    public static let windwardLeeward = Layout(id: UUID(uuidString: "3538DD08-F2A2-489F-957F-FE429684CDD0")!,
                                               name: "Windward/Leeward",
                                               description: "A simple windward/leeward course with a combined start/finish line in the middle of the course.",
                                               loci: [
                                                Locus(bearing: -90,
                                                      distance: .totalBoatLengths(times: 0.75),
                                                      loci: [
                                                        Locus(bearing: -90,
                                                              distance: .totalBoatLengths(times: 0.75),
                                                              mark: MarkSpec(name: "pin")),
                                                        Locus(bearing: 0,
                                                              distance: .adjustable(name: "wind"),
                                                              mark: MarkSpec(name: "wind")),
                                                        Locus(bearing: 180,
                                                              distance: .adjustable(name: "lee"),
                                                              mark: MarkSpec(name: "lee")),
                                                      ])
                                               ])

}
