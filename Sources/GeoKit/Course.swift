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

// Any given course only uses a subset of these Distances,
// but storing all of them makes it easy to switch from one
// course layout to another.
public struct Distances: Codable, Sendable, Equatable {
    public var upwind: Distance = 200
    public var downwind: Distance = 200
    public var width: Distance = 200
    public var offset: Distance = 40
    public var gate: Distance = 40
    public var start: Distance = 100
    public var finish: Distance = 100
    public var finishLine: Distance = 40
    public var trapezoidDownwind: Distance = 200
    
    public subscript(key: DistanceMeasurement) -> Distance {
        get {
            switch key {
            case .upwind:
                return upwind
            case .downwind:
                return downwind
            case .width:
                return width
            case .offset:
                return offset
            case .gate:
                return gate
            case .start:
                return start
            case .finish:
                return finish
            case .finishLine:
                return finishLine
            case .trapezoidDownwind:
                return trapezoidDownwind
            }
        }
        set {
            switch key {
            case .upwind:
                upwind = newValue
            case .downwind:
                downwind = newValue
            case .width:
                width = newValue
            case .offset:
                offset = newValue
            case .gate:
                gate = newValue
            case .start:
                start = newValue
            case .finish:
                finish = newValue
            case .finishLine:
                finishLine = newValue
            case .trapezoidDownwind:
                trapezoidDownwind = newValue
            }
        }
    }
}

public struct TargetLocation {
    public var role: MarkRole
    public var location: Coordinate
}

/**
 The complete state information for a race course, including location of marks,
 target areas for marks, wind direction, and wind speed.
 */
public struct Course: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID = UUID()
    
    public var name: String = ""
    
    /// The location of the committee boat.
    public var startFlag = Coordinate(latitude: 41.777, longitude: -71.379)
    
    /// The location of the finish flag, if the finish boat has anchored.
    public var finishFlag: Coordinate? = nil
    
    public var windHalfLife: TimeInterval = 12.0 * 60.0
    
    /// If the course direction is locked, the current orientation of the course in degrees from true north.
    public var lockedCourseDirection: Direction? = nil
    
    /// The number of sailboats in the regatta, which indirectly determines
    /// the length of the start line.
    public var numberOfBoats: Int = 10
    
    public var boatLength: Distance = sunfishBoatLength
    
    /// The size of the zone in boat lengths. Usually 2 for team racing and
    /// 3 otherwise.
    public var zoneSize: Int = 3
    
    /// The size of each target area on the chart
    public var targetRadius: Distance = 10.0
    
    public var distances = Distances()
    
    /// The coordinates of the physical marks on the course as recorded
    /// by the mark boat.
    public var marks: [Coordinate] = []
    
    public var weatherStationId: String = WeatherStation.providenceVisibility.id
    public var layout: Layout {
        didSet {
            if layout.shape == .digitalN {
                let avg = (distances.upwind + distances.downwind) / 2.0
                distances.start = avg
                distances.finish = avg
            }
        }
    }
    
    /// The length of a Sunfish sailboat in meters.
    public static let sunfishBoatLength: Distance = 4.19
    
    /// Creates a course with default settings for the Providence River
    /// near Edgewood Yacht Club.
    public init() {
        self.layout = .triangleCenterStart
    }
    
    public init(id: UUID, name: String = "", layout: Layout = .triangleCenterStart) {
        self.id = id
        self.name = name
        self.layout = layout
        self.distances = layout.sampleDistances
    }
    
    public init(id: String,
                name: String = "",
                boatLength: Distance = sunfishBoatLength,
                layout: Layout = .triangleCenterStart) {
        self.id = UUID(uuidString: id)!
        self.name = name
        self.layout = layout
        self.boatLength = boatLength
        self.distances = layout.sampleDistances
    }
    
    /// The calculated length of the start line based on the number of boats.
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.sunfishBoatLength * 1.5
    }
    
    public var zoneRadius: Distance {
        return Double(zoneSize) * boatLength
    }
    
    /// Remove all marks from the course, including the finishFlag
    public mutating func pullAllMarks() {
        finishFlag = nil
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
    
    public var targetMarks: [MarkRole] {
        var result: [MarkRole] = []
        for locus in layout.loci {
            locus.forEachMark { result.append($0) }
        }
        return result
    }
    
    public func nearestMark(to target: Coordinate) -> Coordinate? {
        var nearestMark: Coordinate? = nil
        var nearestMarkDistance = Distance.infinity
        for m in marks {
            let d = target.distance(to: m)
            if d < nearestMarkDistance {
                nearestMark = m
                nearestMarkDistance = d
            }
        }
        return nearestMark
    }
    
    public func anyMarkWithinTargetRadius(of target: Coordinate, with role: MarkRole) -> Bool {
        if role == .finishFlag {
            guard let finishFlag else { return false }
            return finishFlag.distance(to: target) <= targetRadius
        }
        else {
            return marks.contains { $0.distance(to: target) <= targetRadius }
        }
    }
}

extension Course {
    public static let theFrozenFew = Course(id: "D4F19F6C-CCC4-4BB8-A376-368671E5C7ED",
                                            name: "The Frozen Few",
                                            layout: .triangleCenterStart)
    public static let optiGreenFleet = Course(id: "E3F4B122-F068-4FAB-9FDD-6996CC1938F6",
                                              name: "Opti green fleet",
                                              layout: .windwardLeewardSimple)
    public static let optiRedWhiteBlueFleet = Course(id: "8E5934D8-7EB4-4AA9-8ECD-8589C0F3ABB2",
                                                     name: "Opti RWB fleet",
                                                     layout: .windwardLeewardFancy)
    public static let brownTeamRacing = Course(id: "E953D6A3-85A5-4CFE-A0B9-43EC9B37AD6B",
                                               name: "Brown team racing",
                                               boatLength: 4.2164,
                                               layout: .digitalN)
    
    public static let all = [theFrozenFew, optiGreenFleet, optiRedWhiteBlueFleet, brownTeamRacing]
    
    public static let kitchenSink =
        Course(id: "307338F1-1354-4221-A617-872C26B05A40",
               name: "The Kitchen Sink")
}

extension Course {
    public init?(json: String) {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else { return nil }
        guard let c = try? decoder.decode(Course.self, from: data) else { return nil }
        self = c
    }
    
    public var jsonString: String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
}
