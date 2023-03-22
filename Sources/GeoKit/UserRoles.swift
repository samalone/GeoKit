//
//  UserRoles.swift
//  
//
//  Created by Stuart A. Malone on 3/22/23.
//

import Foundation

/// UserRoles represent the relationship between a user and a course.
/// A user may have multiple roles on the same course, and their permissions
/// are the union of all the permissions granted by those roles.
///
/// UserRoles are stored in the database and must remain stable over time.
/// But the corresponding permissions are calculated from the roles and
/// may change as the software evolves.
public struct UserRoles: OptionSet, Codable, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// The owner is the person who made the in-app purchase for the course.
    /// They can send invitations to other users and grant them roles.
    ///
    /// When a user creates a new course, they are the owner but are also given
    /// the PRO, markBoat, and finishBoat roles so they can edit everyting on
    /// the course. However, the owner can remove those other roles if they
    /// want to simplify the interface and avoid mistakes.
    public static let owner         = UserRoles(rawValue: 1 << 0)
    
    /// The PRO is the principal race officer who is in charge of the racing.
    /// This person has control over the course layout, size, and direction.
    public static let PRO           = UserRoles(rawValue: 1 << 1)
    
    /// The mark boat is in charge of setting and pulling marks.
    public static let markBoat      = UserRoles(rawValue: 1 << 2)
    
    /// The finish boat is in control of the finish line.
    public static let finishBoat    = UserRoles(rawValue: 1 << 3)
    
    /// An observer can see the map but not change it.
    public static let observer      = UserRoles(rawValue: 1 << 4)
    
    /// The permissions granted by all of the roles
    public var permissions: UserPermissions {
        var perms = UserPermissions.none
        if self.contains(.owner) {
            perms.formUnion([.renameCourse, .grantRoles, .viewCourse, .deleteCourse])
        }
        if self.contains(.PRO) {
            perms.formUnion([.editLayout, .viewCourse, .undoRedo])
        }
        if self.contains(.markBoat) {
            perms.formUnion([.viewCourse, .dropMarks])
        }
        if self.contains(.finishBoat) {
            perms.formUnion([.viewCourse, .setFinishFlag])
        }
        if self.contains(.observer) {
            perms.formUnion([.viewCourse])
        }
        return perms
    }
}
