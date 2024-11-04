//
//  Coordinate.swift
//
//
//  Created by Stuart A. Malone on 2/20/23.
//

import Foundation

// Apple's CoreLocation module declares a structure called
// CLLocationCoordinate2D to store a latitude/longitude pair,
// but it's not available on Linux. We define our own Coordinate
// structure that is compatible with CLLocationCoordinate2D
// on Apple platforms, and implemented from scratch on Linux.

#if canImport(CoreLocation)

    import CoreLocation

    /// A location on the globe in latitude and longitude
    public typealias Coordinate = CLLocationCoordinate2D

    extension CLLocationCoordinate2D: Codable {
        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
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

    extension CLLocationCoordinate2D: @retroactive Equatable {
        public static func == (_ a: Self, _ b: Self) -> Bool {
            (a.latitude == b.latitude) && (a.longitude == b.longitude)
        }
    }

#else

    public struct Coordinate: Codable, Equatable, Sendable {
        public var latitude: Double
        public var longitude: Double

        public init() {
            latitude = 0.0
            longitude = 0.0
        }

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

#endif

extension Coordinate: Location {
    public func isValid() -> Bool {
        (latitude >= -90.0) && (latitude <= 90.0) &&
            (longitude >= -180.0) && (longitude <= 180)
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

    /// Return a new coordinate that is a given bearing and distance from the current coordinate.
    public func project(bearing: Direction, distance: Distance) -> Coordinate {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let distRadians = distance / Distance.earthRadius
        let bearingRadians = bearing.degreesToRadians

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))

        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1),
                                cos(distRadians) - sin(lat1) * sin(lat2))

        return Coordinate(latitude: lat2.radiansToDegrees, longitude: lon2.radiansToDegrees)
    }

    /// Compute the distance in meters between two coordinates.
    public func distance(to: Coordinate) -> Distance {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians

        let distance = acos(sin(lat1) * sin(lat2) +
            cos(lat1) * cos(lat2) *
            cos(lon2 - lon1)) * Distance.earthRadius
        return distance
    }
}
