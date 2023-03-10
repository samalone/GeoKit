//
//  CoordinateRegion.swift
//
//
//  Created by Stuart A. Malone on 3/4/23.
//

import Foundation

#if canImport(MapKit)

    import MapKit
    import CoreLocation

    public typealias CoordinateSpan = MKCoordinateSpan
    public typealias CoordinateRegion = MKCoordinateRegion
    public typealias Degrees = CLLocationDegrees

#else

    public typealias Degrees = Double

    public struct CoordinateSpan {
        public init() {
            self.latitudeDelta = 0
            self.longitudeDelta = 0
        }
        
        public init(latitudeDelta: Degrees, longitudeDelta: Degrees) {
            self.latitudeDelta = latitudeDelta
            self.longitudeDelta = longitudeDelta
        }
        
        public var latitudeDelta: Degrees
        public var longitudeDelta: Degrees
    }

    public struct CoordinateRegion {
        
        public init(center: Coordinate, span: CoordinateSpan) {
            self.center = center
            self.span = CoordinateSpan(latitudeDelta: abs(span.latitudeDelta),
                                       longitudeDelta: abs(span.longitudeDelta))
        }
        
        public init(center: Coordinate, latitudinalMeters: Distance, longitudinalMeters: Distance) {
            self.center = center
            self.span = CoordinateSpan(latitudeDelta: latitudinalMeters / Distance.earthMetersPerDegree,
                                       longitudeDelta: longitudinalMeters / (cos(center.latitude.degreesToRadians) * Distance.earthMetersPerDegree))
        }
        
        public var center: Coordinate
        public var span: CoordinateSpan
    }

#endif

extension CoordinateSpan {
    public static let zero = CoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
}

extension CoordinateRegion {
    
    /// A special region that has no center and spans no space.
    /// It can be used as an initial value to enclose other coordinates and regions.
    public static let undefined = CoordinateRegion(center: Coordinate(latitude: Degrees.nan, longitude: Degrees.nan),
                                            span: CoordinateSpan(latitudeDelta: Degrees.nan, longitudeDelta: Degrees.nan))
    
    public var isUndefined: Bool {
        return center.latitude.isNaN || center.longitude.isNaN || span.latitudeDelta.isNaN || span.longitudeDelta.isNaN
    }
    
    public var minLatitude: Degrees {
        center.latitude - (span.latitudeDelta / 2.0)
    }
    
    public var minLongitude: Degrees {
        center.longitude - (span.longitudeDelta / 2.0)
    }
    
    public var maxLatitude: Degrees {
        center.latitude + (span.latitudeDelta / 2.0)
    }
    
    public var maxLongitude: Degrees {
        center.longitude + (span.longitudeDelta / 2.0)
    }
    
    public var minCorner: Coordinate {
        Coordinate(latitude: minLatitude, longitude: minLongitude)
    }
    
    public var maxCorner: Coordinate {
        Coordinate(latitude: maxLatitude, longitude: maxLongitude)
    }
    
    public init(latitude1: Degrees, longitude1: Degrees, latitude2: Degrees, longitude2: Degrees) {
        let minLat = min(latitude1, latitude2)
        let minLon = min(longitude1, longitude2)
        let maxLat = max(latitude1, latitude2)
        let maxLon = max(longitude1, longitude2)
        self = CoordinateRegion(center: Coordinate(latitude: (minLat + maxLat) / 2.0,
                                                   longitude: (minLon + maxLon) / 2.0),
                                span: CoordinateSpan(latitudeDelta: maxLat - minLat,
                                                     longitudeDelta: maxLon - minLon))
    }
    
    public func enclosing(_ coordinate: Coordinate) -> CoordinateRegion {
        guard !isUndefined else {
            return CoordinateRegion(center: coordinate, span: .zero)
        }
        return CoordinateRegion(latitude1: min(minLatitude, coordinate.latitude),
                                longitude1: min(minLongitude, coordinate.longitude),
                                latitude2: max(maxLatitude, coordinate.latitude),
                                longitude2: max(maxLongitude, coordinate.longitude))
    }
    
    public mutating func enclose(_ coordinate: Coordinate) {
        self = self.enclosing(coordinate)
    }
    
    public func enclosing(_ region: CoordinateRegion) -> CoordinateRegion {
        guard !isUndefined else {
            return region
        }
        return CoordinateRegion(latitude1: min(minLatitude, region.minLatitude),
                                longitude1: min(minLongitude, region.minLongitude),
                                latitude2: max(maxLatitude, region.maxLatitude),
                                longitude2: max(maxLongitude, region.maxLongitude))
    }
    
    public mutating func enclose(_ region: CoordinateRegion) {
        self = self.enclosing(region)
    }
    
    public func scaled(by factor: Double) -> CoordinateRegion {
        CoordinateRegion(center: center,
                         span: CoordinateSpan(latitudeDelta: span.latitudeDelta * factor,
                                              longitudeDelta: span.longitudeDelta * factor))
    }
    
    public mutating func scale(by factor: Double) {
        self = self.scaled(by: factor)
    }
}

extension CoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        let delta = 0.00001
        return (abs(lhs.center.latitude - rhs.center.latitude) < delta) &&
        (abs(lhs.center.longitude - rhs.center.longitude) < delta) &&
        (abs(lhs.span.latitudeDelta - rhs.span.latitudeDelta) < delta) &&
        (abs(lhs.span.longitudeDelta - rhs.span.longitudeDelta) < delta)
    }
}
