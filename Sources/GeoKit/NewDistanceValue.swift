//
//  NewDistanceValue.swift
//  
//
//  Created by Stuart A. Malone on 3/13/23.
//

import Foundation

public struct NewDistanceValue: Codable, Sendable {
    public var measurement: DistanceMeasurement
    public var value: Double
    
    public init(measurement: DistanceMeasurement, value: Double) {
        self.measurement = measurement
        self.value = value
    }
}
