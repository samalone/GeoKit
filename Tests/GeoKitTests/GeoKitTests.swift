@testable import GeoKit
import Testing
import CoreGraphics

extension Double {
    // Define an approximately-equal operator named ~= on Double,
    // with a tolerance of 1e-5 relative to the scale of the values
    static func ~=(lhs: Double, rhs: Double) -> Bool {
        let epsilon = 1e-5
        let scale = max(abs(lhs), abs(rhs), 1.0)
        return abs(lhs - rhs) < epsilon * scale
    }
}

extension Point {
    static func ~=(lhs: Point, rhs: Point) -> Bool {
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
    
    static func ~=(lhs: Point?, rhs: Point) -> Bool {
        guard let lhs else { return false }
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
    
    static func ~=(lhs: Point, rhs: Point?) -> Bool {
        guard let rhs else { return false }
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
}

extension Coordinate {
    static func ~=(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.latitude ~= rhs.latitude && lhs.longitude ~= rhs.longitude
    }
    
    static func ~=(lhs: Coordinate?, rhs: Coordinate) -> Bool {
        guard let lhs else { return false }
        return lhs.latitude ~= rhs.latitude && lhs.longitude ~= rhs.longitude
    }
    
    static func ~=(lhs: Coordinate, rhs: Coordinate?) -> Bool {
        guard let rhs else { return false }
        return lhs.latitude ~= rhs.latitude && lhs.longitude ~= rhs.longitude
    }
}

struct GeoKitTests {
    @Test func testExample() {
        #expect(Distance.earthRadius == 6_372_797.6)
    }
    
    func verifyRelationship(from p0: Point, to p1: Point, bearing: Direction, distance: Distance) {
        let reverseBearing = (bearing + 180.0).truncatingRemainder(dividingBy: 360.0)
        
        #expect(p0.distance(to: p1) ~= distance)
        #expect(p1.distance(to: p0) ~= distance)
        
        #expect(p0.bearing(to: p1) ~= bearing)
        #expect(p1.bearing(to: p0) ~= reverseBearing)
        
        let j1 = p0.project(bearing: bearing, distance: distance)
        #expect(p1.x ~= j1.x)
        #expect(p1.y ~= j1.y)
        
        let j0 = p1.project(bearing: reverseBearing, distance: distance)
        #expect(p0.x ~= j0.x)
        #expect(p0.y ~= j0.y)
    }
    
    @Test func testPoints() throws {
        let p0 = Point()
        let p1 = Point(x: 0, y: -50)
        let p2 = Point(x: 30, y: -40)
        let p3 = Point(x: 40, y: -40)
        let p4 = Point(x: 40, y: -30)
        let p5 = Point(x: 50, y: 0)
        let p6 = Point(x: 40, y: 30)
        let p7 = Point(x: 40, y: 40)
        let p8 = Point(x: 30, y: 40)
        let p9 = Point(x: 0, y: 50)
        
        verifyRelationship(from: p0, to: p1, bearing: 0, distance: 50)
        verifyRelationship(from: p0, to: p2, bearing: 36.86989764584402, distance: 50)
        verifyRelationship(from: p0, to: p3, bearing: 45, distance: 56.568542494923804)
        verifyRelationship(from: p0, to: p4, bearing: 53.13010235415598, distance: 50)
        verifyRelationship(from: p0, to: p5, bearing: 90, distance: 50)
        verifyRelationship(from: p0, to: p6, bearing: 126.86989764584402, distance: 50)
        verifyRelationship(from: p0, to: p7, bearing: 135, distance: 56.568542494923804)
        verifyRelationship(from: p0, to: p8, bearing: 143.13010235415598, distance: 50)
        verifyRelationship(from: p0, to: p9, bearing: 180, distance: 50)
    }
    
    @Test func testPointIntersection() throws {
        let p0 = Point(x: 0, y: 0)
        let p1 = Point(x: 3, y: 0)
        let p2 = Point(x: 6, y: 0)
        
        let sa = atan2(3, 4).radiansToDegrees
//        let la = atan2(4, 3).radiansToDegrees
        
        #expect(p0.intersection(bearing: 45, other: p1, otherBearing: 0) ~= Point(x: 3, y: 3))
        #expect(p0.intersection(bearing: sa,
                                other: p1, otherBearing: 0) ~= Point(x: 3, y: 4))
        #expect(p0.intersection(bearing: sa, other: p2, otherBearing: 360 - sa) ~= Point(x: 3, y: 4))
    }
    
    func verifyIntersection(result: Point,
                            distanceA: Distance, bearingA: Degrees,
                            distanceB: Distance, bearingB: Degrees) {
        // Project pointA out from the result.
        let pointA = result.project(bearing: bearingA, distance: distanceA)
        let pointB = result.project(bearing: bearingB, distance: distanceB)
        
        // Now reverse the calculation by finding the intersection of the
        // vectors from pointA and pointB using reverse bearings.
        let intersection = pointA.intersection(bearing: 180 - bearingA, other: pointB, otherBearing: 180 - bearingB)
        
        #expect(intersection ~= result)
    }
    
    // Test Case 2: Simple Intersection
    @Test func testSimpleIntersection() {
        verifyIntersection(result: Point(x: 0, y: 0),
                           distanceA: 100.0, bearingA: 0.0,
                           distanceB: 100.0, bearingB: 90.0)
        verifyIntersection(result: Point(x: 0, y: 0),
                           distanceA: 100.0, bearingA: 27.0,
                           distanceB: 100.0, bearingB: 59.0)
        for _ in 1...1000 {
            verifyIntersection(result: Point(x: Double.random(in: -100...100), y: Double.random(in: -100...100)),
                               distanceA: Double.random(in: 1...100), bearingA: Double.random(in: 0...360),
                               distanceB: Double.random(in: 1...100), bearingB: Double.random(in: 0...360))
        }
    }

}
