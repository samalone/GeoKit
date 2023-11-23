@testable import GeoKit
import XCTest

final class GeoKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Distance.earthRadius, 6_372_797.6)
    }

    func verifyRelationship(from p0: Point, to p1: Point, bearing: Direction, distance: Distance) {
        let reverseBearing = (bearing + 180.0).truncatingRemainder(dividingBy: 360.0)

        XCTAssertEqual(p0.distance(to: p1), distance, accuracy: 0.01)
        XCTAssertEqual(p1.distance(to: p0), distance, accuracy: 0.01)

        XCTAssertEqual(p0.bearing(to: p1), bearing, accuracy: 0.01)
        XCTAssertEqual(p1.bearing(to: p0), reverseBearing, accuracy: 0.01)

        let j1 = p0.project(bearing: bearing, distance: distance)
        XCTAssertEqual(p1.x, j1.x, accuracy: 0.01)
        XCTAssertEqual(p1.y, j1.y, accuracy: 0.01)

        let j0 = p1.project(bearing: reverseBearing, distance: distance)
        XCTAssertEqual(p0.x, j0.x, accuracy: 0.01)
        XCTAssertEqual(p0.y, j0.y, accuracy: 0.01)
    }

    func testPoints() throws {
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
