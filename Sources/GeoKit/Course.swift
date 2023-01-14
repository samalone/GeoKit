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

/**
 The complete state information for a race course, including location of marks,
 target areas for marks, wind direction, and wind speed.
 */
public struct Course: Codable, Equatable {
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
    
    /// The distance from the center of the start line to the target area
    /// of the windward mark, in meters.
    public var desiredWindwardDistance: Distance = 175
    
    /// The distance from the center of the start line to the target area
    /// of the leeward mark, in meters.
    public var desiredLeewardDistance: Distance = 175
    
    /// The distance from the center of the start line to the target area
    /// of the jibe mark, in meters.
    public var desiredJibeDistance: Distance = 175
    
    /// The coordinates of the physical marks on the course as recorded
    /// by the mark boat.
    public var marks: [Coordinate] = []
    
    /// The length of a Sunfish sailboat in meters.
    public static let sunfishBoatLength: Distance = 4.19
    
    /// Creates a course with default settings for the Providence River
    /// near Edgewood Yacht Club.
    public init() {
    }
    
    /// The calculated length of the start line based on the number of boats.
    public var lengthOfStartLine: Distance {
        return Double(numberOfBoats) * Course.sunfishBoatLength * 1.5
    }
    
    /// The calculated location of the center of the start line, given the
    /// course direction and number of boats.
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
    
    /// Remove all marks from the course.
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
