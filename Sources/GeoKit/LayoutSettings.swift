//
//  LayoutSettings.swift
//  
//
//  Created by Stuart A. Malone on 2/2/23.
//

import Foundation

public enum CourseShape: String, CaseIterable, Codable, Sendable {
    /// No jibe mark (windward/leeward course)
    case windwardLeeward
    
    /// A single jibe mark (triangle course)
    case triangle
    
    /// Two jibe marks, (trapezoid course)
    case trapezoid
    
    /// College team racing Digital N course
    case digitalN
}

extension CourseShape: Identifiable {
    public var id: CourseShape { self }
}

public enum StartLinePlacement: String, CaseIterable, Codable, Sendable {
    /// Between the wind and leeward marks
    case midCourse
    
    /// The leeward mark is also the pin
    case atLeewardMark
    
    /// Downwind of the leeward mark
    case downwind
}

extension StartLinePlacement: Identifiable {
    public var id: StartLinePlacement { self }
}

public enum FinishLinePlacement: String, CaseIterable, Codable, Sendable {
    /// The start line is also the finish line
    case sharedWithStartLine
    
    /// On the starboard side of the committee boat
    case starboardOfStartFlag
    
    /// Upwind of the windward mark
    case upwind
    
    /// The wind mark is also the pin for the finish line
    case atWindMark
    
    /// The finish line is downwind of the main course,
    /// perpendicular to the last mark
    case downwindReach
}

extension FinishLinePlacement: Identifiable {
    public var id: FinishLinePlacement { self }
}

public enum WindMarkOption: String, CaseIterable, Codable, Sendable {
    case singleMark
    case markAndOffset
}

extension WindMarkOption: Identifiable {
    public var id: WindMarkOption { self }
}

public enum LeewardMarkOption: String, CaseIterable, Codable, Sendable {
    case singleMark
    
    case gate
    
    /// Leeward mark with offset, only used with Digital N course
    case markAndOffset
}

extension LeewardMarkOption: Identifiable {
    public var id: LeewardMarkOption { self }
}

extension Array {
    fileprivate func plus(_ newElement: Element?) -> [Element] {
        guard let newElement else { return self }
        var result = self
        result.append(newElement)
        return result
    }
    
    fileprivate func plus(_ newElements: [Element]) -> [Element] {
        guard !newElements.isEmpty else { return self }
        var result = self
        result.append(contentsOf: newElements)
        return result
    }
}

/// LayoutSettings are my attempt to create a taxonomy of sailboat racing courses.
/// The idea is to present the user with a set of multiple-choice options that will allow them
/// to create nearly any common race course layout.
///
/// These options are not entirely independent of one another. However, my goal is to
/// have a natural order to the choices so the user can make a sequence of choices in
/// order and at each step only be presented with the options that make sense given
/// the previous choices.
///
/// For instance, the Digital N course implies windward and leeward offsets and
/// a separate finish line, so once the user has chosen the Digital N course, most
/// or all of the other choices should disappear.
///
/// Most of Proper Course does not use LayoutSettings directly. Instead LayoutSettings
/// generate a tree of Locus objects that describe in polar coordinates where the marks should go.
/// These loci are lower-level and more powerful than LayoutSettings, but they are
/// too abstract for most users to interact with directly.
public struct LayoutSettings: Equatable, Codable, Sendable {
    public var shape: CourseShape = .triangle {
        didSet { updateStart() }
    }
    public var start: StartLinePlacement = .midCourse {
        didSet { updateFinish() }
    }
    public var finish: FinishLinePlacement = .sharedWithStartLine {
        didSet { updateWind() }
    }
    public var wind: WindMarkOption = .singleMark {
        didSet { updateLee() }
    }
    public var lee: LeewardMarkOption = .singleMark
    
    public init(shape: CourseShape, start: StartLinePlacement, finish: FinishLinePlacement, wind: WindMarkOption, lee: LeewardMarkOption) {
        self.shape = shape
        self.start = start
        self.finish = finish
        self.wind = wind
        self.lee = lee
    }
    
    private mutating func updateStart() {
        let choices = startChoices
        if !choices.contains(start), let first = choices.first {
            start = first
        }
        updateFinish()
    }
    
    private mutating func updateFinish() {
        let choices = finishChoices
        if !choices.contains(finish), let first = choices.first {
            finish = first
        }
        updateWind()
    }
    
    private mutating func updateWind() {
        let choices = windChoices
        if !choices.contains(wind), let first = choices.first {
            wind = first
        }
        updateLee()
    }
    
    private mutating func updateLee() {
        let choices = leeChoices
        if !choices.contains(lee), let first = choices.first {
            lee = first
        }
    }
    
    public var startChoices: [StartLinePlacement] {
        switch shape {
        case .windwardLeeward, .triangle, .trapezoid:
            return [.midCourse, .atLeewardMark, .downwind]
        case .digitalN:
            return [.downwind]
        }
    }
    
    public var finishChoices: [FinishLinePlacement] {
        switch shape {
        case .windwardLeeward, .triangle, .trapezoid:
            switch start {
            case .midCourse, .atLeewardMark:
                return [.sharedWithStartLine, .starboardOfStartFlag, .upwind, .atWindMark, .downwindReach]
            case .downwind:
                return [.upwind, .atWindMark, .downwindReach]
            }
        case .digitalN:
            return [.upwind]
        }
    }
    
    public var windChoices: [WindMarkOption] {
        switch shape {
        case .windwardLeeward, .triangle, .trapezoid:
            return [.singleMark, .markAndOffset]
        case .digitalN:
            return [.markAndOffset]
        }
    }
    
    public var leeChoices: [LeewardMarkOption] {
        switch shape {
        case .windwardLeeward, .triangle, .trapezoid:
            switch start {
            case .midCourse, .downwind:
                return [.singleMark, .gate]
            case .atLeewardMark:
                return [.singleMark]
            }
        case .digitalN:
            return [.markAndOffset]
        }
    }
    
    /// The position of the wind marks relative to the center of the course
    var windMarkLocus: Locus {
        switch wind {
        case .singleMark:
            return Locus(bearing: 0,
                         distance: .adjustable(measurement: .upwind),
                         mark: .windward,
                         loci: windMarkRelativeLoci)
        case .markAndOffset:
            return Locus(bearing: 0,
                         distance: .adjustable(measurement: .upwind),
                         mark: .windward,
                         loci: [
                            Locus(bearing: -90,
                                  distance: .adjustable(measurement: .offset),
                                  mark: .windwardOffset)
                         ].plus(windMarkRelativeLoci))
        }
    }
    
    var windMarkRelativeLoci: [Locus] {
        switch finish {
        case .sharedWithStartLine, .starboardOfStartFlag, .downwindReach:
            return []
        case .upwind:
            return [
                Locus(bearing: 0,
                      distance: .adjustable(measurement: .finish),
                      loci: [
                        Locus(bearing: 90,
                              distance: .adjustable(measurement: .finishLine, times: 0.5),
                              mark: .finishFlag),
                        Locus(bearing: -90,
                              distance: .adjustable(measurement: .finishLine, times: 0.5),
                              mark: .finishPin)
                      ])
            ]
        case .atWindMark:
            return [
                Locus(bearing: 90,
                      distance: .adjustable(measurement: .finishLine),
                      mark: .finishFlag)
            ]
        }
    }
    
    /// The position of the leeward marks relative to the center of the start line
    var leewardMarkLocus: Locus {
        // The position of the leeward mark depends on how the start line
        // is positioned relative to the course
        let bearing: Direction
        let distance: DistanceCalculation
        
        switch start {
        case .midCourse:
            bearing = 180
            distance = .adjustable(measurement: .downwind)
        case .atLeewardMark:
            bearing = -90
            distance = .totalBoatLengths(times: 0.75)
        case .downwind:
            bearing = 0
            distance = .adjustable(measurement: .start)
        }
        
        switch lee {
        case .singleMark:
            return Locus(bearing: bearing,
                         distance: distance,
                         mark: .leeward)
        case .gate:
            return Locus(bearing: bearing,
                         distance: distance,
                         loci: [
                            Locus(bearing: 90,
                                  distance: .adjustable(measurement: .gate, times: 0.5),
                                  mark: .leewardGateLeft),
                            Locus(bearing: -90,
                                  distance: .adjustable(measurement: .gate, times: 0.5),
                                  mark: .leewardGateRight)
                         ])
        case .markAndOffset:
            // Note that in practice this case is never used, since .markAndOffset
            // is only available when shape == .digitalN, and that course is
            // hard-coded.
            return Locus(bearing: bearing,
                         distance: distance,
                         mark: .leeward,
                         loci: [
                            Locus(bearing: 90,
                                  distance: .adjustable(measurement: .offset),
                                  mark: .leewardOffset)
                         ])
        }
    }
    
    /// The position of the jibe marks relative to the center of the course
    var jibeMarkLocus: Locus? {
        switch shape {
        case .windwardLeeward:
            return nil
        case .triangle:
            return Locus(bearing: -90,
                         distance: .adjustable(measurement: .width),
                         mark: .jibe)
        case .trapezoid:
            return Locus(bearing: -90,
                         distance: .adjustable(measurement: .width),
                         loci: [
                            Locus(bearing: 0,
                                  distance: .adjustable(measurement: .trapezoidDownwind, times: 0.5),
                                  mark: .windwardJibe),
                            Locus(bearing: 180,
                                  distance: .adjustable(measurement: .trapezoidDownwind, times: 0.5),
                                  mark: .leewardJibe)
                         ])
        case .digitalN:
            return nil
        }
    }
    
    var startFlagRelativeLoci: Locus? {
        switch finish {
        case .sharedWithStartLine, .upwind, .atWindMark, .downwindReach:
            return nil
        case .starboardOfStartFlag:
            return Locus(bearing: 90,
                         distance: .adjustable(measurement: .finishLine),
                         mark: .finishPin)
        }
    }
    
    public var loci: [Locus] {
        // The Digital N course is such a special case that we just hard-wire
        // the loci and don't allow the user to change any other settings.
        guard shape != .digitalN else {
            return Layout.digitalN.loci
        }
        
        // IMPORTANT: Since Locus is a struct rather than a class, all of the
        // fields of a Locus must be set BEFORE it is appended to the loci of
        // another Locus. Any changes made after it is appended will have no
        // effect.
        
        // Since we lay the course out relative to the start line, we need
        // to sort that out before we can position other loci.
        switch start {
        case .midCourse:
            return [
                Locus(bearing: -90,
                                distance: .totalBoatLengths(times: 1.5),
                                mark: .startPin),
                Locus(bearing: -90,
                      distance: .totalBoatLengths(times: 0.75),
                      isCourseCenter: true,
                      loci: [windMarkLocus, leewardMarkLocus].plus(jibeMarkLocus))
            ].plus(startFlagRelativeLoci)
        case .atLeewardMark:
            return [
                Locus(bearing: -90,
                      distance: .totalBoatLengths(times: 0.75),
                      loci: [
                        leewardMarkLocus,
                        Locus(bearing: 0,
                              distance: .adjustable(measurement: .downwind),
                              isCourseCenter: true,
                              loci: [windMarkLocus].plus(jibeMarkLocus))
                      ])
            ].plus(startFlagRelativeLoci)
        case .downwind:
            return [
                Locus(bearing: -90,
                      distance: .totalBoatLengths(times: 1.5),
                      mark: .startPin),
                Locus(bearing: -90,
                      distance: .totalBoatLengths(times: 0.75),
                      loci: [
                        leewardMarkLocus,
                        Locus(bearing: 0,
                              distance: .adjustable(measurement: .start),
                              loci: [
                                leewardMarkLocus,
                                Locus(bearing: 0,
                                      distance: .adjustable(measurement: .downwind),
                                      isCourseCenter: true,
                                      loci: [windMarkLocus].plus(jibeMarkLocus))
                              ])
                      ])
            ].plus(startFlagRelativeLoci)
        }
    }
    
    /// A reasonable set of starting Distances for this course layout.
    /// This can be used as starting values for a course, or just to
    /// display a representative layout to the user.
    public var sampleDistances: Distances {
        switch shape {
        case .windwardLeeward, .triangle, .trapezoid:
            return Distances()
        case .digitalN:
            return Distances(upwind: 200, downwind: 200, offset: 80, start: 200, finish: 200)
        }
    }
    
    
    /// Return the distance measurements that are actually used in the layout
    public var usedMeasurements: [DistanceMeasurement] {
        var names: [DistanceMeasurement] = []
        for locus in loci {
            locus.forEachDistanceMeasurement {
                if !names.contains($0) {
                    names.append($0)
                }
            }
        }
        return names
    }
    
    /// A simple triangle course with the start line mid-course
    public static let triangleCenterStart = LayoutSettings(shape: .triangle, start: .midCourse, finish: .sharedWithStartLine,
                                                           wind: .singleMark, lee: .singleMark)
    
    /// A windward-leeward course with separate start and finish lines mid-course, a windward offset, and a leeward gate.
    public static let windwardLeewardSimple = LayoutSettings(shape: .windwardLeeward, start: .midCourse, finish: .starboardOfStartFlag,
                                                             wind: .markAndOffset, lee: .gate)
    
    /// A windward-leeward course with separate start and finish lines mid-course, a windward offset, and a leeward gate.
    public static let windwardLeewardFancy = LayoutSettings(shape: .windwardLeeward, start: .midCourse, finish: .starboardOfStartFlag,
                                                            wind: .markAndOffset, lee: .gate)
    
    /// The Digital N course used in team racing
    public static let digitalN = LayoutSettings(shape: .digitalN, start: .downwind, finish: .upwind,
                                                wind: .markAndOffset, lee: .markAndOffset)
    
    
    
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

