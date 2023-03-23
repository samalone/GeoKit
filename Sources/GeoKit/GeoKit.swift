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

extension Distance {
    /// An initial value for course leg distances, if no previous value is available.
    public static let defaultCourseLeg: Distance = 200.0
    
    /// The average radius of the Earth in meters
    public static let earthRadius: Distance = 6372797.6
    public static let earthMetersPerDegree: Distance = earthRadius * pi / 180.0
}

/// Wind speed in knots
public typealias WindSpeed = Double

extension Double {
    public var degreesToRadians: Double { return self * .pi / 180 }
    public var radiansToDegrees: Double { return self * 180 / .pi }
    
    public var feetToMeters: Double { return self * 0.3048 }
    public var metersToFeet: Double { return self * 3.28084 }
    
    public var mphToKnots: Double { return self * 0.8689762419 }
    public var knotsToMph: Double { return self * 1.150779448 }
    
    public var mpsToKnots: Double { return self * 1.9438444924 }
    public var knotsToMps: Double { return self * 0.5144444444 }
}
