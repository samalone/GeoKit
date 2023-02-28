//
//  LayoutSettings.swift
//  
//
//  Created by Stuart A. Malone on 2/2/23.
//

import Foundation

public enum CourseShape {
    /// No jibe mark (windward/leeward course)
    case windwardLeeward
    
    /// A single jibe mark (triangle course)
    case triangle
    
    /// Two jibe marks, (trapezoid course)
    case trapezoid
}

public enum StartLinePlacement {
    /// Between the wind and leeward marks
    case midCourse
    
    /// The leeward mark is also the pin
    case atLeewardMark
    
    /// Downwind of the leeward mark
    case downwind
}

public enum FinishLinePlacement {
    /// The start line is also the finish line
    case sharedWithStartLine
    
    /// On the starboard side of the committee boat
    case starboardOfSignal
    
    /// Upwind of the windward mark
    case upwind
    
    /// The wind mark is also the pin for the finish line
    case atWindMark
    
    /// The finish line is downwind of the main course,
    /// perpendicular to the last mark
    case downwindReach
}

public enum WindMarkOption {
    case singleMark
    case markAndOffset
}

public enum LeewardMarkOption {
    case singleMark
    case gate
}

public struct LayoutSettings {
    public var shape: CourseShape = .triangle
    public var start: StartLinePlacement = .midCourse
    public var finish: FinishLinePlacement = .sharedWithStartLine
    public var wind: WindMarkOption = .singleMark
    public var lee: LeewardMarkOption = .singleMark
    
    public init(shape: CourseShape, start: StartLinePlacement, finish: FinishLinePlacement, wind: WindMarkOption, lee: LeewardMarkOption) {
        self.shape = shape
        self.start = start
        self.finish = finish
        self.wind = wind
        self.lee = lee
    }
    
    var windMarkLocus: Locus {
        var windCenter = Locus(bearing: 0,
                          distance: .adjustable(name: "wind"))
        switch wind {
        case .singleMark:
            windCenter.mark = MarkSpec(name: "Wind")
            
        case .markAndOffset:
            windCenter.loci.append(Locus(bearing: 90,
                                         distance: .adjustable(name: "offset", times: 0.5),
                                         mark: MarkSpec(name: "Wind")))
            windCenter.loci.append(Locus(bearing: -90,
                                         distance: .adjustable(name: "offset", times: 0.5),
                                    mark: MarkSpec(name: "Offset")))
        }
        
        return windCenter
    }
    
    var leewardMarkLocus: Locus {
        var locus: Locus
        switch start {
        case .midCourse:
            locus = Locus(bearing: 180,
                          distance: .adjustable(name: "lee"))
        case .atLeewardMark:
            locus = Locus(bearing: -90,
                          distance: .totalBoatLengths(times: 0.75))
        case .downwind:
            locus = Locus(bearing: 0,
                          distance: .adjustable(name: "lee"))
        }
        switch lee {
        case .singleMark:
            locus.mark = MarkSpec(name: "lee")
        case .gate:
            locus.loci = [
                Locus(bearing: -90,
                      distance: .adjustable(name: "gate", times: 0.5),
                      mark: MarkSpec(name: "left gate")),
                Locus(bearing: 90,
                      distance: .adjustable(name: "gate", times: 0.5),
                      mark: MarkSpec(name: "right gate"))
            ]
        }
        return locus
    }
    
    public var loci: [Locus] {
        var centerOfStartLine = Locus(bearing: -90,
                                      distance: .totalBoatLengths(times: 0.75))
        
        centerOfStartLine.loci.append(windMarkLocus)
        centerOfStartLine.loci.append(leewardMarkLocus)
        
        let pin = Locus(bearing: -90,
                        distance: .totalBoatLengths(times: 1.5),
                        mark: MarkSpec(name: "Pin"))
        
        return [centerOfStartLine, pin]
    }
    
    
    
//    func generateLayout() -> Layout {
//        var startPin = Locus(bearing: -90, distance: .totalBoatLengths(times: 1.5), mark: MarkSpec(name: "pin"))
//        var centerOfStartLine = Locus(bearing: -90, distance: .totalBoatLengths(times: 0.75))
//        
//        // Since we lay out the course from the committee boat (signal),
//        // a lot depends on the placement of the start line.
//        var windLocus: Locus
//        switch start {
//        case .midCourse:
//            centerOfStartLine.loci.append(<#T##newElement: Locus##Locus#>)
//        }
//    }
}

