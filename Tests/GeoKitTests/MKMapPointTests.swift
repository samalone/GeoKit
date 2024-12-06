#if canImport(MapKit)
import Testing
import MapKit
@testable import GeoKit

extension MKMapPoint {
    static func ~= (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
        lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
}

struct MKMapPointTests {
    
    func verify1(a: MKMapPoint, b: MKMapPoint, i: MKMapPoint) throws {
        let aBearing = a.bearing(to: i)
        let bBearing = b.bearing(to: i)
        
        let actualI = try #require(a.intersection(bearing: aBearing, other: b, otherBearing: bBearing))
        #expect(i ~= actualI)
    }
    
    func verify6(a: MKMapPoint, b: MKMapPoint, i: MKMapPoint) throws {
        try verify1(a: a, b: b, i: i)
        try verify1(a: b, b: a, i: i)
        try verify1(a: i, b: a, i: b)
        try verify1(a: i, b: b, i: a)
        try verify1(a: a, b: i, i: b)
        try verify1(a: b, b: i, i: a)
    }
    
    @Test func testBearing() throws {
        let a = MKMapPoint(x: 0, y: 0)
        let b = MKMapPoint(x: 0, y: 6)
        let i = MKMapPoint(x: 4, y: 3)
        
        let smallBearing = 36.86989764584402
        let largeBearing = 53.13010235415598
        
        #expect(a.bearing(to: b) ~= 180.0)
        #expect(b.bearing(to: a) ~= 0.0)
        #expect(a.bearing(to: i) ~= 180.0 - largeBearing)
        #expect(i.bearing(to: a) ~= 360.0 - largeBearing)
        #expect(b.bearing(to: i) ~= largeBearing)
        #expect(i.bearing(to: b) ~= 180 + largeBearing)
    }

    @Test func testIntersection() throws {
        try verify6(a: MKMapPoint(x: 0, y: 0), b: MKMapPoint(x: 0, y: 6), i: MKMapPoint(x: 4, y: 3))
    }
    
    @Test func testDistance() throws {
        let a = MKMapPoint(x: 0, y: 0)
        let b = MKMapPoint(x: 0, y: 600)
        let i = MKMapPoint(x: 400, y: 300)
        
        // Note that x and y are in unspecified units, not meters.
        // However, the result of the distance function is in meters.
        
        let ab = a.distance(to: b)
        let ai = a.distance(to: i)
        let bi = b.distance(to: i)
        
        #expect(ab / ai ~= 6.0 / 5.0)
        #expect(ab / bi ~= 6.0 / 5.0)
        #expect(ai / bi ~= 1.0)
    }
}
#endif
