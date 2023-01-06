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

public struct Coordinate: Codable, Equatable {
    public static let earthRadius: Double = 6372797.6
    
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func isValid() -> Bool {
        return (-90.0 <= latitude) && (latitude <= 90.0) &&
        (-180.0 <= longitude) && (longitude <= 180)
    }
}

public struct Course: Codable, Equatable {
    public var signal = Coordinate(latitude: 41.777, longitude: -71.379)
    public var windDirection: Double = 0.0
    public var windSpeed: Double = 0.0
    public var windGusts: Double = 0.0
    public var numberOfBoats: Int = 10
    public var actualWindMarkLocation: Coordinate? = nil
    public var actualJybeMarkLocation: Coordinate? = nil
    public var actualLeewardMarkLocation: Coordinate? = nil
    public var actualPinLocation: Coordinate? = nil
    public var desiredWindwardDistance: Double = 400
    public var desiredLeewardDistance: Double = 400
    public var desiredJybeDistance: Double = 400
    
    public static let boatLength: Distance = 4.19
    
    public init() {
    }
    
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.boatLength * 1.5
    }
    
    public var desiredCenterOfStartLine: Coordinate {
        return signal.project(bearing: windDirection - 90, distance: lengthOfStartLine / 2)
    }
    
    public var desiredPinLocation: Coordinate {
        return signal.project(bearing: windDirection - 90, distance: lengthOfStartLine)
    }
    
    public var desiredJybeMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: windDirection - 90, distance: desiredJybeDistance)
    }
    
    public var desiredWindMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: windDirection, distance: desiredWindwardDistance)
    }
    
    public var desiredLeewardMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: windDirection + 180, distance: desiredLeewardDistance)
    }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
    
    var feetToMeters: Double { return self * 0.3048 }
    var metersToFeet: Double { return self * 3.28084 }
}

extension Coordinate {
    public func bearing(to: Coordinate) -> Direction {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearingInDegrees = atan2(y, x).radiansToDegrees
        
        return (bearingInDegrees < 0) ? (bearingInDegrees + 360) : bearingInDegrees
    }
    
    public func project(bearing: Direction, distance: Distance) -> Coordinate {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let distRadians = distance / Coordinate.earthRadius
        let bearingRadians = bearing.degreesToRadians
        
        let lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1),
                                cos(distRadians) - sin(lat1) * sin(lat2))
        
        return Coordinate(latitude: lat2.radiansToDegrees, longitude: lon2.radiansToDegrees)
    }
    
    public func distance(to: Coordinate) -> Distance {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let distance = acos(sin(lat1) * sin(lat2) +
                            cos(lat1) * cos(lat2) *
                            cos(lon2 - lon1)) * Coordinate.earthRadius
        return distance
    }
}