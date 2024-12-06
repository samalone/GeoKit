//
//  GeoKit.swift
//
//
//  Created by Stuart Malone on 1/2/23.
//

import Foundation

/// Compass direction in degrees from true north
public typealias Direction = Double

/// Compute the angular difference between two directions.
/// The difference is positive if the second direction is clockwise from the first,
/// and negative if the second direction is counterclockwise from the first.
/// The result will be in the range -180.0 to 180.0 degrees.
public func angularDifference(_ start: Direction, _ end: Direction) -> Direction {
    let diff = end - start
    // Since diff can be as negative as -360, add 540 instead of 180 to
    // ensure the result is always positive
    return (diff + 540.0).truncatingRemainder(dividingBy: 360.0) - 180.0
}

/// Distance in meters
public typealias Distance = Double

public extension Distance {
    /// An initial value for course leg distances, if no previous value is available.
    static let defaultCourseLeg: Distance = 200.0

    /// The average radius of the Earth in meters
    static let earthRadius: Distance = 6_372_797.6
    static let earthMetersPerDegree: Distance = earthRadius * pi / 180.0
}

/// Wind speed in knots
public typealias WindSpeed = Double

public extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }

    var feetToMeters: Double { self * 0.3048 }
    var metersToFeet: Double { self * 3.28084 }

    var mphToKnots: Double { self * 0.8689762419 }
    var knotsToMph: Double { self * 1.150779448 }

    var mpsToKnots: Double { self * 1.9438444924 }
    var knotsToMps: Double { self * 0.5144444444 }
}
