//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 1/14/23.
//

import Foundation

public struct WindInformation: Equatable, Codable {
    public var station: WeatherStation
    
    /// The start of the 6-minute interval this data represents, in GMT
    public var startTime: Date
    
    public var endTime: Date {
        return startTime.addingTimeInterval(360.0)
    }
    
    /// The latest wind direction, measured in degress from true north.
    public var direction: Direction
    
    /// The latest wind speed in knots.
    public var speed: Double
    
    /// The latest wind gusts in knots
    public var gusts: Double
    
    public init(station: WeatherStation = WeatherStation(),
                startTime: Date = Date.distantPast,
                direction: Direction = 0,
                speed: Double = 0,
                gusts: Double = 0) {
        self.station = station
        self.startTime = startTime
        self.direction = direction
        self.speed = speed
        self.gusts = gusts
    }
}
