//
//  Layout.swift
//  
//
//  Created by Stuart A. Malone on 1/12/23.
//

import Foundation
#if canImport(CoreLocation)
    import CoreLocation
#endif
#if canImport(CoreGraphics)
    import CoreGraphics
#endif

public enum DistanceUnit: Double {
    case meters = 1.0
    case feet = 3.280839895013123
    case yards = 1.093613298337708
}

public struct SliderSettings {
    public let min: Double
    public let max: Double
    public let step: Double
}

public enum DistanceMeasurement: String, Codable, Sendable {
    /// The distance from the center of the course to the windward marks
    case upwind
    
    /// The distance from the center of the course to the leeward marks
    case downwind
    
    /// The separation between the jibe mark(s) and the
    /// main upwind/downwind portion of the course
    case width
    
    /// The length of the short downwind leg of a trapezoid course
    case trapezoidDownwind
    
    /// The distance from a mark to its associated offset
    case offset
    
    /// The distance between marks in a gate
    case gate
    
    /// The distance from the start line to the main course
    case start
    
    /// This is the distance from the main course to the finish line
    case finish
    
    /// The length of the finish line
    case finishLine
    
    static let largeMeterSlider = SliderSettings(min: 100, max: 300, step: 25)
    static let largeFootSlider = SliderSettings(min: 300, max: 900, step: 75)
    
    static let smallMeterSlider = SliderSettings(min: 30, max: 100, step: 10)
    static let smallFootSlider = SliderSettings(min: 100, max: 300, step: 25)
    
    public func sliderSettings(for unit: DistanceUnit) -> SliderSettings {
        switch self {
        case .upwind, .downwind, .width, .start, .finish, .trapezoidDownwind:
            switch unit {
            case .meters, .yards:
                return Self.largeMeterSlider
            case .feet:
                return Self.largeFootSlider
            }
        case .offset, .gate, .finishLine:
            switch unit {
            case .meters, .yards:
                return Self.smallMeterSlider
            case .feet:
                return Self.smallFootSlider
            }
        }
    }
}

extension DistanceMeasurement: Identifiable {
    public var id: DistanceMeasurement { self }
}
