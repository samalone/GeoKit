//
//  LayoutSettings.swift
//  
//
//  Created by Stuart A. Malone on 2/2/23.
//

import Foundation

enum CourseShape {
    /// No jibe mark (windward/leeward course)
    case windwardLeeward
    
    /// A single jibe mark (triangle course)
    case triangle
    
    /// Two jibe marks, (trapezoid course)
    case trapezoid
}

enum StartLinePlacement {
    /// Between the wind and leeward marks
    case midCourse
    
    /// The leeward mark is also the pin
    case atLeewardMark
    
    /// Downwind of the leeward mark
    case downwind
}

enum FinishLinePlacement {
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

enum WindMarkOption {
    case singleMark
    case markAndOffset
}

enum LeewardMarkOption {
    case singleMark
    case gate
}

struct LayoutSettings {
    var shape: CourseShape = .triangle
    var start: StartLinePlacement = .midCourse
    var finish: FinishLinePlacement = .sharedWithStartLine
    var wind: WindMarkOption = .singleMark
    var lee: LeewardMarkOption = .singleMark
    
    var windMarkLocus: Locus {
        var locus = Locus(bearing: 0,
                          distance: .adjustable(name: "wind"),
                          mark: MarkSpec(name: "wind", hasZone: true))
        switch wind {
        case .singleMark:
            break
        case .markAndOffset:
            locus.loci.append(Locus(bearing: -90,
                                    distance: .adjustable(name: "offset"),
                                    mark: MarkSpec(name: "offset", hasZone: true)))
        }
        
        return locus
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
            locus.mark = MarkSpec(name: "lee", hasZone: true)
        case .gate:
            locus.loci = [
                Locus(bearing: -90,
                      distance: .adjustable(name: "gate", times: 0.5),
                      mark: MarkSpec(name: "left gate", hasZone: true)),
                Locus(bearing: 90,
                      distance: .adjustable(name: "gate", times: 0.5),
                      mark: MarkSpec(name: "right gate", hasZone: true))
            ]
        }
        return locus
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

