//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 1/14/23.
//

import Foundation

public struct WeatherStation: Identifiable, Equatable, Codable {
    /// The 7-digit ID of the weather station
    public var id: String
    
    /// The name of the weather station
    public var name: String
    
    /// The location of the weather station
    public var location: Coordinate
    
    public init(id: String = "", name: String = "", location: Coordinate = Coordinate(latitude: 0, longitude: 0)) {
        self.id = id
        self.name = name
        self.location = location
    }
    
    static let providenceVisibility = WeatherStation(id: "8453662",
                                                     name: "Providence Visibility",
                                                     location: Coordinate(latitude: 41.7857, longitude: -71.3831))
}
