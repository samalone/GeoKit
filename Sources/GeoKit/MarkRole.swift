//
//  MarkRole.swift
//  
//
//  Created by Stuart A. Malone on 3/11/23.
//

import Foundation

public enum MarkRole: Codable, CaseIterable {
    /// The committee boat end of the start line, usually marked with an orange flag.
    case startFlag
    
    /// The pin end of the start line
    case startPin
    
    /// The committee boat end of the finish line, usually marked with a blue flag.
    case finishFlag
    
    /// The pin end of the finish line
    case finishPin
    
    case windward
    
    case windwardOffset
    
    case leeward
    
    case leewardOffset
    
    case leewardGateLeft
    case leewardGateRight
    
    case jibe
    
    case windwardJibe
    case leewardJibe
    
    /// A mark without a specified role. This identifies marks dropped on the course,
    /// which can change role over time as the wind shifts. Layouts should always use
    /// more specific roles for their targets.
    case genericMark
    
    public var isFlag: Bool {
        (self == .startFlag) || (self == .finishFlag)
    }
    
    public var isMark: Bool {
        !isFlag
    }
}

extension MarkRole: Identifiable {
    public var id: MarkRole { self }
}
