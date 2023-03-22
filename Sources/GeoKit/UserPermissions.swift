//
//  UserPermissions.swift
//  
//
//  Created by Stuart A. Malone on 3/22/23.
//

import Foundation

/// UserPermissions control which parts of the user interface are enabled,
/// and which server operations the user can perform.
///
/// UserPermissions are not stored in the database so they can evolve over time
/// without having to migrate any data.
public struct UserPermissions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let renameCourse     = UserPermissions(rawValue: 1 << 0)
    public static let editLayout       = UserPermissions(rawValue: 1 << 1)
    public static let grantRoles       = UserPermissions(rawValue: 1 << 2)
    public static let viewCourse       = UserPermissions(rawValue: 1 << 3)
    public static let undoRedo         = UserPermissions(rawValue: 1 << 4)
    public static let deleteCourse     = UserPermissions(rawValue: 1 << 5)
    public static let dropMarks        = UserPermissions(rawValue: 1 << 6)
    public static let setFinishFlag    = UserPermissions(rawValue: 1 << 7)
    
    public static let none: UserPermissions = []
}
