//
//  CoordinateRegion.swift
//
//
//  Created by Stuart A. Malone on 3/4/23.
//

import Foundation

#if canImport(MapKit)

    import CoreLocation
    import MapKit

    public typealias CoordinateSpan = MKCoordinateSpan
    public typealias CoordinateRegion = MKCoordinateRegion
    public typealias Degrees = CLLocationDegrees

    extension CoordinateRegion: @retroactive Equatable {
        public static func == (lhs: CoordinateRegion, rhs: CoordinateRegion) -> Bool {
            let delta = 0.00001
            return (abs(lhs.center.latitude - rhs.center.latitude) < delta) &&
            (abs(lhs.center.longitude - rhs.center.longitude) < delta) &&
            (abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta) < delta) &&
            (abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta) < delta)
        }
    }

#else

    /// An angle in degrees. This may represent an angle, latitude, or longitude.
    public typealias Degrees = Double

    /// A structure that represents the span of a region on the globe in latitude and longitude.
    /// This structure is compatible with MKCoordinateSpan on Apple platforms.
    public struct CoordinateSpan: Sendable {
        public init() {
            latitudeDelta = 0
            longitudeDelta = 0
        }

        public init(latitudeDelta: Degrees, longitudeDelta: Degrees) {
            self.latitudeDelta = latitudeDelta
            self.longitudeDelta = longitudeDelta
        }

        public var latitudeDelta: Degrees
        public var longitudeDelta: Degrees
    }

    /// A structure that represents a region on the globe in latitude and longitude.
    /// This structure is compatible with MKCoordinateRegion on Apple platforms.
    public struct CoordinateRegion: Sendable {
        public init(center: Coordinate, span: CoordinateSpan) {
            self.center = center
            self.span = CoordinateSpan(latitudeDelta: abs(span.latitudeDelta),
                                       longitudeDelta: abs(span.longitudeDelta))
        }

        public init(center: Coordinate, latitudinalMeters: Distance, longitudinalMeters: Distance) {
            self.center = center
            span = CoordinateSpan(latitudeDelta: latitudinalMeters / Distance.earthMetersPerDegree,
                                  longitudeDelta: longitudinalMeters / (cos(center.latitude.degreesToRadians) * Distance.earthMetersPerDegree))
        }

        public var center: Coordinate
        public var span: CoordinateSpan
    }

#endif

public extension CoordinateSpan {
    static let zero = CoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
}

public extension CoordinateRegion {
    /// A special region that has no center and spans no space.
    /// It can be used as an initial value to enclose other coordinates and regions.
    static let undefined = CoordinateRegion(center: Coordinate(latitude: Degrees.nan, longitude: Degrees.nan),
                                            span: CoordinateSpan(latitudeDelta: Degrees.nan, longitudeDelta: Degrees.nan))

    var isUndefined: Bool {
        center.latitude.isNaN || center.longitude.isNaN || span.latitudeDelta.isNaN || span.longitudeDelta.isNaN
    }

    var minLatitude: Degrees {
        center.latitude - (span.latitudeDelta / 2.0)
    }

    var minLongitude: Degrees {
        center.longitude - (span.longitudeDelta / 2.0)
    }

    var maxLatitude: Degrees {
        center.latitude + (span.latitudeDelta / 2.0)
    }

    var maxLongitude: Degrees {
        center.longitude + (span.longitudeDelta / 2.0)
    }

    var minCorner: Coordinate {
        Coordinate(latitude: minLatitude, longitude: minLongitude)
    }

    var maxCorner: Coordinate {
        Coordinate(latitude: maxLatitude, longitude: maxLongitude)
    }

    init(latitude1: Degrees, longitude1: Degrees, latitude2: Degrees, longitude2: Degrees) {
        let minLat = min(latitude1, latitude2)
        let minLon = min(longitude1, longitude2)
        let maxLat = max(latitude1, latitude2)
        let maxLon = max(longitude1, longitude2)
        self = CoordinateRegion(center: Coordinate(latitude: (minLat + maxLat) / 2.0,
                                                   longitude: (minLon + maxLon) / 2.0),
                                span: CoordinateSpan(latitudeDelta: maxLat - minLat,
                                                     longitudeDelta: maxLon - minLon))
    }

    func enclosing(_ coordinate: Coordinate) -> CoordinateRegion {
        guard !isUndefined else {
            return CoordinateRegion(center: coordinate, span: .zero)
        }
        return CoordinateRegion(latitude1: min(minLatitude, coordinate.latitude),
                                longitude1: min(minLongitude, coordinate.longitude),
                                latitude2: max(maxLatitude, coordinate.latitude),
                                longitude2: max(maxLongitude, coordinate.longitude))
    }

    mutating func enclose(_ coordinate: Coordinate) {
        self = enclosing(coordinate)
    }

    func enclosing(_ region: CoordinateRegion) -> CoordinateRegion {
        guard !isUndefined else {
            return region
        }
        return CoordinateRegion(latitude1: min(minLatitude, region.minLatitude),
                                longitude1: min(minLongitude, region.minLongitude),
                                latitude2: max(maxLatitude, region.maxLatitude),
                                longitude2: max(maxLongitude, region.maxLongitude))
    }

    mutating func enclose(_ region: CoordinateRegion) {
        self = enclosing(region)
    }

    func scaled(by factor: Double) -> CoordinateRegion {
        CoordinateRegion(center: center,
                         span: CoordinateSpan(latitudeDelta: span.latitudeDelta * factor,
                                              longitudeDelta: span.longitudeDelta * factor))
    }

    mutating func scale(by factor: Double) {
        self = scaled(by: factor)
    }
}
