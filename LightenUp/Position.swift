//
//  Position.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/11.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct Position: Equatable, Comparable {
    var row = 0
    var col = 0
    init(_ r: Int, _ c: Int) {
        row = r; col = c
    }
}

func + (left: Position, right: Position) -> Position {
    return Position(left.row + right.row, left.col + right.col)
}

func - (left: Position, right: Position) -> Position {
    return Position(left.row - right.row, left.col - right.col)
}

prefix func + (x: Position) -> Position {
    return x
}

prefix func - (x: Position) -> Position {
    return Position(-x.row, -x.col)
}

func += (inout left: Position, right: Position) {
    left = left + right
}

func -= (inout left: Position, right: Position) {
    left = left - right
}

func == (left: Position, right: Position) -> Bool {
    return left.row == right.row && left.col == right.col
}

func < (left: Position, right: Position) -> Bool {
    return (left.row, left.col) < (right.row, right.col)
}
