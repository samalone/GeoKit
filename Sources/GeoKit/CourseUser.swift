//
//  User.swift
//  
//
//  Created by Stuart A. Malone on 3/22/23.
//

import Foundation

/// A CourseUser represents someone who can access a course,
/// and their role(s) on the race committee. A user's roles control what
/// permissions they have and therefore what actions they can take.
public struct CourseUser: Codable, Sendable {
    public var id: UUID
    
    public var name: String
    
    public var roles: UserRoles
}
