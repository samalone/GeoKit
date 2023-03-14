//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/13/23.
//

import Foundation

public enum CourseAction: Int16, RawRepresentable, Codable, Sendable {
    /// Reset the course to default values.
    case reset = 0
    
    /// Set the direction of the course. [Direction]
    case setCourseDirection = 1
    
    /// Set whether the course direction is locked. [Bool]
    case setIsCourseDirectionLocked = 2
    
    /// Set the number of boats racing. [Int]
    case setNumberOfBoats = 3
    
    /// Set a distance measurement. [NewDistanceValue]
    case setDistance = 4
    
    /// Remove all marks and the finish flag from the course.
    case pullAllMarks = 5
    
    /// Drop a mark at a location. [Coordinate]
    case dropMark = 6
    
    /// Pull the nearest mark to a location. [Coordinate]
    case pullNearestMark = 7
    
    /// Set the location of the start flag. [Coodinate]
    case setStartFlag = 8
    
    /// Set the location of the finish flag. [Coordinate]
    case setFinishFlag = 9
    
    /// Clear the location of the finish flag.
    case clearFinishFlag = 10
    
    /// Set the number of seconds for wind averaging. [Double]
    case setWindHalfLife = 11
}
