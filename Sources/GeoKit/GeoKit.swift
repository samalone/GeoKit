//
//  GeoKit.swift
//
//
//  Created by Stuart Malone on 1/2/23.
//

import Foundation

/// Compass direction in degrees from true north
public typealias Direction = Double

/// Distance in meters
public typealias Distance = Double

public extension Distance {
    /// An initial value for course leg distances, if no previous value is available.
    static let defaultCourseLeg: Distance = 200.0
    
    /// The average radius of the Earth in meters
    static let earthRadius: Distance = 6372797.6
    static let earthMetersPerDegree: Distance = earthRadius * pi / 180.0
}

/// Wind speed in knots
public typealias WindSpeed = Double

public extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
    
    var feetToMeters: Double { return self * 0.3048 }
    var metersToFeet: Double { return self * 3.28084 }
    
    var mphToKnots: Double { return self * 0.8689762419 }
    var knotsToMph: Double { return self * 1.150779448 }
    
    var mpsToKnots: Double { return self * 1.9438444924 }
    var knotsToMps: Double { return self * 0.5144444444 }
}
