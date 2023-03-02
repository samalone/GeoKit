//
//  Course.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation
#if canImport(CoreLocation)
    import CoreLocation
#endif

extension Sequence where Element == Distance {
    var median: Double {
        let v = Array(self).sorted()
        guard v.count > 0 else { return .defaultCourseLeg }
        let i = v.count / 2
        return v[i]
    }
}

/**
 The complete state information for a race course, including location of marks,
 target areas for marks, wind direction, and wind speed.
 */
public struct Course: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID = UUID()
    
    public var name: String = ""
    
    /// The location of the committee boat.
    public var signal = Coordinate(latitude: 41.777, longitude: -71.379)
    
    public var wind: WindInformation = WindInformation()
    
    /// The current orientation of the course in degrees from true north.
    public var courseDirection: Direction = 0.0
    
    /// Is the courseDirection locked independently of the windDirection?
    public var isCourseDirectionLocked: Bool = false
    
    /// The number of sailboats in the regatta, which indirectly determines
    /// the length of the start line.
    public var numberOfBoats: Int = 10
    
    public var boatLength: Distance = sunfishBoatLength
    
    public var distances: Dictionary<DistanceMeasurement, Distance> = [.upwind: 200, .downwind: 200, .width: 200]
    
    /// The coordinates of the physical marks on the course as recorded
    /// by the mark boat.
    public var marks: [Coordinate] = []
    
    public var weatherStationId: String = WeatherStation.providenceVisibility.id
    public var layoutId: UUID = Layout.triangle.id
    
    /// The length of a Sunfish sailboat in meters.
    public static let sunfishBoatLength: Distance = 4.19
    
    /// Creates a course with default settings for the Providence River
    /// near Edgewood Yacht Club.
    public init() {
    }
    
    public init(id: String, name: String, distances: Dictionary<DistanceMeasurement, Distance> = [:]) {
        self.id = UUID(uuidString: id)!
        self.name = name
        self.distances = distances
    }
    
    /// The calculated length of the start line based on the number of boats.
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.sunfishBoatLength * 1.5
    }
    
    /// Remove all marks from the course.
    public mutating func pullAllMarks() {
        marks = []
    }
    
    /// Add a mark at the given coordinate
    public mutating func dropMark(at: Coordinate) {
        // Prevent duplicates, since they are pointless and confuse the SwifUI Map view.
        if !marks.contains(at) {
            marks.append(at)
        }
    }
    
    /// Remove the mark nearest to the given coordinate.
    public mutating func pullMark(near location: Coordinate) {
        switch marks.count {
        case 0:
            return
        case 1:
            marks = []
        default:
            var index = 0
            var d = location.distance(to: marks[0])
            for i in 1 ..< marks.count {
                let d2 = location.distance(to: marks[i])
                if d2 < d {
                    d = d2
                    index = i
                }
            }
            marks.remove(at: index)
        }
    }
    
    public mutating func setDistance(measurement: DistanceMeasurement, to distance: Distance) {
        distances[measurement] = distance
    }
    
    /**
     Change the course to use the provided Layout.
     
     This updates the layoutId and ensures that the course distances
     match the ones in the layout.
     */
    public mutating func changeLayout(to layout: Layout) {
        var newDistances: [DistanceMeasurement: Distance] = [:]
        let medianDistance = distances.values.median
        for newName in layout.distanceMeasurements {
            newDistances[newName] = distances[newName] ?? medianDistance
        }
        layoutId = layout.id
        distances = newDistances
    }
    
}

extension Course {
    public static let theFrozenFew = Course(id: "D4F19F6C-CCC4-4BB8-A376-368671E5C7ED",
                                     name: "The Frozen Few",
                                            distances: [.upwind: 200, .downwind: 200, .width: 200])
    public static let optiGreenFleet = Course(id: "E3F4B122-F068-4FAB-9FDD-6996CC1938F6",
                                       name: "Opti green fleet")
    public static let optiRedWhiteBlueFleet = Course(id: "8E5934D8-7EB4-4AA9-8ECD-8589C0F3ABB2",
                                              name: "Opti red/white/blue fleet")
    
    public static let kitchenSink =
        Course(id: "307338F1-1354-4221-A617-872C26B05A40",
               name: "The Kitchen Sink",
               distances: [.upwind: 200, .downwind: 200, .width: 200, .offset: 40, .gate: 60])
}
