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

/// Wind speed in knots
public typealias WindSpeed = Double

/// The average radius of the Earth in meters
public let earthRadius: Distance = 6372797.6

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
    
    var feetToMeters: Double { return self * 0.3048 }
    var metersToFeet: Double { return self * 3.28084 }
    
    var mphToKnots: Double { return self * 0.8689762419 }
    var knotsToMph: Double { return self * 1.150779448 }
    
    var mpsToKnots: Double { return self * 1.9438444924 }
    var knotsToMps: Double { return self * 0.5144444444 }
}

#if canImport(CoreLocation)

import CoreLocation

/// A location on the globe in latitude and longitude
public typealias Coordinate = CLLocationCoordinate2D

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decode(Double.self, forKey: .latitude)
        let lon = try values.decode(Double.self, forKey: .longitude)
        self = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (_ a: Self, _ b: Self) -> Bool {
        return (a.latitude == b.latitude) && (a.longitude == b.longitude)
    }
}

#else

public struct Coordinate: Codable, Equatable {
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

#endif

extension Coordinate {
    
    public func isValid() -> Bool {
        return (-90.0 <= latitude) && (latitude <= 90.0) &&
        (-180.0 <= longitude) && (longitude <= 180)
    }
    
    /// The bearing from this coordinate to another coordinate, in degress from true north.
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
        let distRadians = distance / earthRadius
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
                            cos(lon2 - lon1)) * earthRadius
        return distance
    }
}
