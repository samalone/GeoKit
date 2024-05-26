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

    public struct Point {
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

    extension Point: Codable, Equatable, Hashable {}

#endif

extension Point: Location {
    public func bearing(to: Point) -> Direction {
        let dx = to.x - x
        let dy = y - to.y
        let b = Double(atan2(dx, dy)).radiansToDegrees
        return (b < 0)
            ? Direction(value: b + 360.0, unit: .degrees)
            : Direction(value: b, unit: .degrees)
    }

    public func project(bearing: Direction, distance: Distance) -> Point {
        let b = bearing.converted(to: .radians).value
        let d = distance.converted(to: .meters).value
        return Point(x: x + d * sin(b), y: y - d * cos(b))
    }

    public func distance(to: Point) -> Distance {
        let dx = x - to.x
        let dy = y - to.y
        return Distance(value: sqrt((dx * dx) + (dy * dy)), unit: .meters)
    }
}
