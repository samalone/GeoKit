//
//  MKMapPoint.swift
//  GeoKit
//
//  Created by Stuart Malone on 12/3/24.
//

import Foundation
#if canImport(MapKit)
import MapKit

extension MKMapPoint: Location {
    
    public func bearing(to: MKMapPoint) -> Direction {
        let dx = to.x - x
        let dy = y - to.y
        let b = Double(atan2(dx, dy)).radiansToDegrees
        return (b < 0) ? (b + 360.0) : b
    }
    
    public func project(bearing: Direction, distance: Distance) -> MKMapPoint {
        let b = bearing.degreesToRadians
        return MKMapPoint(x: x + distance * sin(b), y: y - distance * cos(b))
    }
    
    public func nativeDistance(to: MKMapPoint) -> Distance {
        let dx = x - to.x
        let dy = y - to.y
        return sqrt((dx * dx) + (dy * dy))
    }
    
    public func intersection(bearing: Direction, other: MKMapPoint, otherBearing: Direction) -> MKMapPoint? {
        // Convert bearings from degrees to radians
        let angle1 = bearing.degreesToRadians
        let angle2 = otherBearing.degreesToRadians

        // Direction vectors (adjusted for Y increasing south)
        let dir1 = Point(x: sin(angle1), y: -cos(angle1))
        let dir2 = Point(x: sin(angle2), y: -cos(angle2))

        // Calculate denominator
        let denominator = dir1.x * dir2.y - dir1.y * dir2.x
        if denominator == 0 {
            // Lines are parallel
            return nil
        }

        // Calculate differences
        let dx = other.x - self.x
        let dy = other.y - self.y

        // Calculate parameters
        let t = (dx * dir2.y - dy * dir2.x) / denominator

        // Calculate intersection point
        let intersectionX = self.x + t * dir1.x
        let intersectionY = self.y + t * dir1.y

        return MKMapPoint(x: intersectionX, y: intersectionY)
    }
    
    public func midpoint(to other: MKMapPoint) -> MKMapPoint {
        let x = (self.x + other.x) / 2
        let y = (self.y + other.y) / 2
        return MKMapPoint(x: x, y: y)
    }
}
#endif
