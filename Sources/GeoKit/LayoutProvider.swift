//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 3/2/23.
//

import Foundation

protocol LayoutProvider {
    func findLayout(id: UUID) -> Layout?
}

struct MockLayoutProvider: LayoutProvider {
    func findLayout(id: UUID) -> Layout? {
        for layout in [Layout.triangle, Layout.windwardLeeward, Layout.digitalN] {
            if layout.id == id {
                return layout
            }
        }
        return nil
    }
}

var layoutProvider = MockLayoutProvider()
