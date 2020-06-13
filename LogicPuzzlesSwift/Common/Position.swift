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
}

