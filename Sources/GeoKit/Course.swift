//
//  Course.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation

public struct Course: Codable, Equatable {
    public var signal = Coordinate(latitude: 41.777, longitude: -71.379)
    public var windDirection: Double = 0.0
    public var courseDirection: Double = 0.0
    public var isCourseDirectionLocked: Bool = false
    public var windSpeed: Double = 0.0
    public var windGusts: Double = 0.0
    public var numberOfBoats: Int = 10
    public var desiredWindwardDistance: Double = 175
    public var desiredLeewardDistance: Double = 175
    public var desiredJibeDistance: Double = 175
    public var marks: [Coordinate] = []
    
    public static let sunfishBoatLength: Distance = 4.19
    
    public init() {
    }
    
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.sunfishBoatLength * 1.5
    }
    
    public var desiredCenterOfStartLine: Coordinate {
        return signal.project(bearing: courseDirection - 90, distance: lengthOfStartLine / 2)
    }
    
    public var desiredPinLocation: Coordinate {
        return signal.project(bearing: courseDirection - 90, distance: lengthOfStartLine)
    }
    
    public var desiredJibeMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: courseDirection - 90, distance: desiredJibeDistance)
    }
    
    public var desiredWindMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: courseDirection, distance: desiredWindwardDistance)
    }
    
    public var desiredLeewardMarkLocation: Coordinate {
        return desiredCenterOfStartLine.project(bearing: courseDirection + 180, distance: desiredLeewardDistance)
    }
    
    public mutating func clearAllMarks() {
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
    public mutating func pullMark(at: Coordinate) {
        switch marks.count {
        case 0:
            return
        case 1:
            marks = []
        default:
            var index = 0
            var d = at.distance(to: marks[0])
            for i in 1 ..< marks.count {
                let d2 = at.distance(to: marks[i])
                if d2 < d {
                    d = d2
                    index = i
                }
            }
            marks.remove(at: index)
        }
    }
    
}
