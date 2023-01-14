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
    
    public init(id: String = "", name: String = "", location: Coordinate = Coordinate()) {
        self.id = id
        self.name = name
        self.location = location
    }
}
