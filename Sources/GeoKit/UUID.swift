//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 4/18/23.
//

import Foundation

#if os(Linux)
    public extension UUID: Sendable {}
#endif
