//
//  Location.swift
//
//
//  Created by Stuart A. Malone on 2/20/23.
//

import Foundation

public protocol Location {
    func bearing(to: Self) -> Direction
    func project(bearing: Direction, distance: Distance) -> Self
    func distance(to: Self) -> Distance
    func intersection(bearing: Direction, other: Self, otherBearing: Direction) -> Self?
    func midpoint(to other: Self) -> Self
}
