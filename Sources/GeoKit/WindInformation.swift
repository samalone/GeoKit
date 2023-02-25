//
//  WindInformation.swift
//  
//
//  Created by Stuart A. Malone on 1/14/23.
//

import Foundation

public struct WindInformation: Equatable, Codable {
    /// The start of the 6-minute interval this data represents, in GMT
    public var startTime: Date
    
    public var endTime: Date {
        return startTime.addingTimeInterval(360.0)
    }
    
    /// The latest wind direction, measured in degress from true north.
    public var direction: Direction
    
    /// The latest wind speed in knots.
    public var speed: WindSpeed
    
    /// The latest wind gusts in knots
    public var gusts: WindSpeed
    
    public init(startTime: Date = Date.distantPast,
                direction: Direction = 0,
                speed: WindSpeed = 0,
                gusts: WindSpeed = 0) {
        self.startTime = startTime
        self.direction = direction
        self.speed = speed
        self.gusts = gusts
    }
}
