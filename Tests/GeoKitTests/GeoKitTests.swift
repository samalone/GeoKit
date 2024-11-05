@testable import GeoKit
import Testing

extension Double {
    // Define an approximately-equal operator named ~= on Double,
    // with a tolerance of 0.01
    static func ~=(lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) < 0.01
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
        verifyRelationship(from: p0, to: p2, bearing: 36.87, distance: 50)
        verifyRelationship(from: p0, to: p3, bearing: 45, distance: 56.57)
        verifyRelationship(from: p0, to: p4, bearing: 53.13, distance: 50)
        verifyRelationship(from: p0, to: p5, bearing: 90, distance: 50)
        verifyRelationship(from: p0, to: p6, bearing: 126.87, distance: 50)
        verifyRelationship(from: p0, to: p7, bearing: 135, distance: 56.57)
        verifyRelationship(from: p0, to: p8, bearing: 143.13, distance: 50)
        verifyRelationship(from: p0, to: p9, bearing: 180, distance: 50)
    }
}
