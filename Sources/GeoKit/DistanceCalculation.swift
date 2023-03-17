//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/17/23.
//

import Foundation

public enum DistanceCalculation: Equatable, Codable {
    /**
     This distance is some multiple of the total lengths of the boats
     in the regatta.
     */
    case totalBoatLengths(times: Double)
    
    /**
     This distance is adjustable at race time by the race committee.
     If several distances share the same name, then the UI should
     display a single slider that adjusts all of the distances together.
     */
    case adjustable(measurement: DistanceMeasurement, times: Double = 1.0)
}

extension DistanceCalculation {
    func compute(course: Course) -> Distance {
        switch self {
        case .totalBoatLengths(let times):
            return times * Double(course.numberOfBoats) * course.boatLength
        case .adjustable(let measurement, let times):
            return course.distances[measurement] * times
        }
    }
}
