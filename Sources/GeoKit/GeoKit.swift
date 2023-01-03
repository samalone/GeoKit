//
//  GeoKit.swift
//
//
//  Created by Stuart Malone on 1/2/23.
//

import Foundation


/// Compass direction in degrees from true north
public typealias Direction = Double

/// Distance in meters
public typealias Distance = Double

public struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func isValid() -> Bool {
        return (-90.0 <= latitude) && (latitude <= 90.0) &&
        (-180.0 <= longitude) && (longitude <= 180)
    }
}

//@Published var signal = CLLocationCoordinate2D(latitude: 41.777, longitude: -71.379)
//@Published var windDirection: CLLocationDirection = 0
//@Published var numberOfBoats = 10
//@Published var actualWindMarkLocation = CLLocationCoordinate2D(latitude: 41.777, longitude: -71.379)
//@Published var actualJybeMarkLocation = CLLocationCoordinate2D(latitude: 41.777, longitude: -71.379)
//@Published var actualLeewardMarkLocation = CLLocationCoordinate2D(latitude: 41.777, longitude: -71.379)
//@Published var actualPinLocation = CLLocationCoordinate2D(latitude: 41.777, longitude: -71.379)
//@Published var desiredWindwardDistance: CLLocationDistance = 500
//@Published var desiredLeewardDistance: CLLocationDistance = 500
//@Published var desiredJybeDistance: CLLocationDistance = 600

struct Course: Codable {
    var signal = Coordinate(latitude: 41.777, longitude: -71.379)
    var windDirection: Double = 0.0
    var numberOfBoats: Int = 10
    var actualWindMarkLocation: Coordinate? = nil
    var actualJybeMarkLocation: Coordinate? = nil
    var actualLeewardMarkLocation: Coordinate? = nil
    var actualPinLocation: Coordinate? = nil
    var desiredWindwardDistance: Double = 500
    var desiredLeewardDistance: Double = 500
    var desiredJybeDistance: Double = 500
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
    
    var feetToMeters: Double { return self * 0.3048 }
    var metersToFeet: Double { return self * 3.28084 }
}

let earthRadius: Double = 6372797.6
let sunfishLength: Double = (14.0).feetToMeters

extension Coordinate {
    func bearing(to: Coordinate) -> Direction {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearingInDegrees = atan2(y, x).radiansToDegrees
        
        return (bearingInDegrees < 0) ? (bearingInDegrees + 360) : bearingInDegrees
    }
    
    func project(bearing: Direction, distance: Distance) -> Coordinate {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let distRadians = distance / earthRadius
        let bearingRadians = bearing.degreesToRadians
        
        let lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1),
                                cos(distRadians) - sin(lat1) * sin(lat2))
        
        return Coordinate(latitude: lat2.radiansToDegrees, longitude: lon2.radiansToDegrees)
    }
    
    func distance(to: Coordinate) -> Distance {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let distance = acos(sin(lat1) * sin(lat2) +
                            cos(lat1) * cos(lat2) *
                            cos(lon2 - lon1)) * earthRadius
        return distance
    }
}
