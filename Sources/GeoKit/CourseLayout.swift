//
//  CourseLayout.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation

public enum DistanceCalculation {
    /**
     This distance is some multiple of the total lengths of the boats
     in the regatta.
     */
    case totalBoatLengths(times: Double)
    
    /**
     This distance is adjustable at race time by the race committee.
     If several loci share the same adjustable name, then the UI should
     display a single slider that adjusts all of the loci together.
     */
    case adjustable(name: String)
}

/**
 A MarkSpec is simply an identifier for a location on the course
 where the race committee should place a mark.
 */
public struct MarkSpec {
    /// The name of the mark
    public var name: String

    /// Should the UI draw a zone around the mark?
    public var hasZone: Bool = true
}

/**
 A CourseLocus is an interesting point on the race course.
 Sometimes there will be a mark at the locus, but other times
 a locus is simply a reference point for other loci.
 
 The root locus for the course is the location of the committee boat.
 */
public struct CourseLocus {
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
    public var loci: [CourseLocus] = []
}

public struct CourseLayout {
    public var name: String
    public var id: UUID
    
    /// The loci that are positioned relative to the committee boat.
    public var loci: [CourseLocus]
}
//
//public let triangleCourse =
//    CourseLayout(name: "Triangle",
//                 uuid: UUID(uuidString: "EF24BF8B-E5B9-4E7A-9E47-46E8CED73E79")!,
//                 legs: [
//                    CourseLeg(name: "line",
//                              bearing: -90,
//                              distance: <#T##DistanceCalculation#>)
//                 ])
