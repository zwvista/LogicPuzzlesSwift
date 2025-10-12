//
//  Position.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/11.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct Position: Equatable, Comparable, Hashable, CustomStringConvertible {
    private(set) var row = 0
    private(set) var col = 0
    
    init(_ r: Int, _ c: Int) {
        row = r
        col = c
    }
    
    init() {
        self.init(0, 0)
    }
    
    func unapply() -> (Int, Int) {
        (row, col)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
    
    var description: String {
        "(\(row),\(col))"
    }
    
    static func + (left: Position, right: Position) -> Position {
        Position(left.row + right.row, left.col + right.col)
    }
    
    static func - (left: Position, right: Position) -> Position {
        Position(left.row - right.row, left.col - right.col)
    }
    
    static prefix func + (x: Position) -> Position {
        x
    }
    
    static prefix func - (x: Position) -> Position {
        Position(-x.row, -x.col)
    }
    
    static func += (left: inout Position, right: Position) {
        left = left + right
    }
    
    static func -= (left: inout Position, right: Position) {
        left = left - right
    }
    
    static func == (left: Position, right: Position) -> Bool {
        left.row == right.row && left.col == right.col
    }
    
    static func < (left: Position, right: Position) -> Bool {
        (left.row, left.col) < (right.row, right.col)
    }

    static let North = Position(-1,  0)
    static let NorthEast = Position(-1,  1)
    static let East = Position(0,  1)
    static let SouthEast = Position(1,  1)
    static let South = Position(1,  0)
    static let SouthWest = Position(1, -1)
    static let West = Position(0, -1)
    static let NorthWest = Position(-1, -1)
    static let Zero = Position(0,  0)

    static let Directions4 = [
        Position.North,
        Position.East,
        Position.South,
        Position.West,
    ]
    static let Directions8 = [
        Position.North,
        Position.NorthEast,
        Position.East,
        Position.SouthEast,
        Position.South,
        Position.SouthWest,
        Position.West,
        Position.NorthWest,
    ]
    static let WallsOffset4 = [
        Position.Zero, // North
        Position.East,
        Position.South,
        Position.Zero, // West
    ]
    static let Square2x2Offset = [
        Position.Zero,        // 2*2 nw
        Position.East,        // 2*2 ne
        Position.South,       // 2*2 sw
        Position.SouthEast,   // 2*2 se
    ]
}
