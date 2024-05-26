//
//  GeoKit.swift
//
//
//  Created by Stuart Malone on 1/2/23.
//

import Foundation

/// Compass direction in degrees from true north
public typealias Direction = Measurement<UnitAngle>

public extension Direction {
    static func degrees(_ value: Double) -> Direction {
        return Measurement(value: value, unit: .degrees)
    }
    
    var inDegrees: Double {
        converted(to: .degrees).value
    }
    
    var inRadians: Double {
        converted(to: .radians).value
    }
}

/// Distance in meters
public typealias Distance = Measurement<UnitLength>

public extension Distance {
    static func meters(_ value: Double) -> Distance {
        return Measurement(value: value, unit: .meters)
    }
    
    /// An initial value for course leg distances, if no previous value is available.
    static let defaultCourseLeg: Distance = .meters(200)
    
    /// The average radius of the Earth in meters
    static let earthRadius: Distance = .meters(6_372_797.6)
    static let earthMetersPerDegree: Distance = earthRadius * Double.pi / 180.0
    
    static let zero: Distance = .meters(0)
    static let infinity: Distance = .meters(Double.infinity)
    
    static func / (lhs: Distance, rhs: Distance) -> Double {
        lhs.converted(to: .meters).value / rhs.converted(to: .meters).value
    }
    
    static func * (lhs: Distance, rhs: Double) -> Distance {
        .meters(lhs.converted(to: .meters).value * rhs)
    }
    
    var inMeters: Double {
        converted(to: .meters).value
    }
}

/// Wind speed in knots
public typealias WindSpeed = Measurement<UnitSpeed>

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
