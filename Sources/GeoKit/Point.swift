//
//  Point.swift
//
//
//  Created by Stuart A. Malone on 2/19/23.
//

import Foundation

#if canImport(CoreGraphics)

    import CoreGraphics

    public typealias Point = CGPoint

#else

    /// A structure that represents a point in a two-dimensional coordinate system.
    /// This structure is compatible with CGPoint on Apple platforms.
    public struct Point: Codable, Equatable, Hashable, Sendable {
        public init() {
            x = 0
            y = 0
        }

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        public var x: Double
        public var y: Double

        public static let zero = Point(x: 0, y: 0)
    }

#endif

extension Point: Location {
    public func bearing(to: Point) -> Direction {
        let dx = to.x - x
        let dy = y - to.y
        let b = Double(atan2(dx, dy)).radiansToDegrees
        return (b < 0) ? (b + 360.0) : b
    }

    public func project(bearing: Direction, distance: Distance) -> Point {
        let b = bearing.degreesToRadians
        return Point(x: x + distance * sin(b), y: y - distance * cos(b))
    }

    public func distance(to: Point) -> Distance {
        let dx = x - to.x
        let dy = y - to.y
        return sqrt((dx * dx) + (dy * dy))
    }

    public func intersection(bearing: Direction, other: Point, otherBearing: Direction) -> Point? {
        // Convert bearings from degrees to radians
        let angle1 = (90.0 - bearing).degreesToRadians
        let angle2 = (90.0 - otherBearing).degreesToRadians

        // Direction vectors
        let dir1 = Point(x: cos(angle1), y: sin(angle1))
        let dir2 = Point(x: cos(angle2), y: sin(angle2))

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

        return Point(x: intersectionX, y: intersectionY)
    }
    
    public func midpoint(to other: Point) -> Point {
        Point(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }
}
