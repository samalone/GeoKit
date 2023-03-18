//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/18/23.
//

import Foundation

public struct RemoteCourseStack: CourseStack, Codable, Sendable {
    public var current: CourseState
    public var canUndo: Bool
    public var canRedo: Bool
    
    public init(current: CourseState, canUndo: Bool = false, canRedo: Bool = false) {
        self.current = current
        self.canUndo = canUndo
        self.canRedo = canRedo
    }
}
