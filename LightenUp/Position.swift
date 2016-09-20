//
//  Position.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/11.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct Position: Equatable, Comparable, Hashable, CustomStringConvertible {
    private(set) var row = 0
    private(set) var col = 0
    
    init(_ r: Int, _ c: Int) {
        row = r; col = c
    }
    
    init() {
        self.init(0, 0)
    }
    
    var hashValue: Int {
        return row * 100 + col
    }
    
    var description: String {
        return "(\(row),\(col))"
    }
    
    static func + (left: Position, right: Position) -> Position {
        return Position(left.row + right.row, left.col + right.col)
    }
    
    static func - (left: Position, right: Position) -> Position {
        return Position(left.row - right.row, left.col - right.col)
    }
    
    static prefix func + (x: Position) -> Position {
        return x
    }
    
    static prefix func - (x: Position) -> Position {
        return Position(-x.row, -x.col)
    }
    
    static func += (left: inout Position, right: Position) {
        left = left + right
    }
    
    static func -= (left: inout Position, right: Position) {
        left = left - right
    }
    
    static func == (left: Position, right: Position) -> Bool {
        return left.row == right.row && left.col == right.col
    }
    
    static func < (left: Position, right: Position) -> Bool {
        return (left.row, left.col) < (right.row, right.col)
    }
}

