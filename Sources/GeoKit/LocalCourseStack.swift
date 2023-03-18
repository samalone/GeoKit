//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/18/23.
//

import Foundation

public struct LocalCourseStack: CourseStack, Codable {
    static let stackLimit = 20

    public private(set) var current: CourseState
    var undoStack: [Course] = []
    var redoStack: [Course] = []
    
    public init(course: Course) {
        current = CourseState(course)
    }
    
    public var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    public var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    /// Returns the current state of the CourseStack in a form that can
    /// be transmitted remotely.
    public var asRemote: RemoteCourseStack {
        RemoteCourseStack(current: current, canUndo: canUndo, canRedo: canRedo)
    }
    
    public var windHistory: [WindInformation] {
        get {
            current.windHistory
        }
        set {
            current.windHistory = newValue
        }
    }
    
    public mutating func modify(canUndo: Bool = true, action: (inout Course) -> ()) {
        if canUndo {
            pushUndo(clearRedo: true)
        }
        action(&current.course)
    }
    
    mutating func pushUndo(clearRedo: Bool) {
        if undoStack.count >= LocalCourseStack.stackLimit {
            undoStack.removeFirst(LocalCourseStack.stackLimit - undoStack.count + 1)
        }
        undoStack.append(current.course)
        if clearRedo {
            redoStack = []
        }
    }
    
    mutating func pushRedo() {
        if redoStack.count >= LocalCourseStack.stackLimit {
            redoStack.removeFirst(LocalCourseStack.stackLimit - redoStack.count + 1)
        }
        redoStack.append(current.course)
    }
    
    @discardableResult
    public mutating func undo() -> Bool {
        guard let c = undoStack.popLast() else { return false }
        pushRedo()
        current.course = c
        return true
    }
    
    @discardableResult
    public mutating func redo() -> Bool {
        guard let c = redoStack.popLast() else { return false }
        pushUndo(clearRedo: false)
        current.course = c
        return true
    }
}
