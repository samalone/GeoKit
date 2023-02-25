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
    }

    extension Point: Codable, Equatable, Hashable {}

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
}
