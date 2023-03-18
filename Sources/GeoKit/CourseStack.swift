//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/18/23.
//

import Foundation

@dynamicMemberLookup
public protocol CourseStack {
    var current: CourseState { get }
    var canUndo: Bool { get }
    var canRedo: Bool { get }
}

extension CourseStack {
    public var course: Course {
        current.course
    }
    
    public var windHistory: [WindInformation] {
        current.windHistory
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Course, T>) -> T {
        current.course[keyPath: keyPath]
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<CourseState, T>) -> T{
        current[keyPath: keyPath]
    }
}
