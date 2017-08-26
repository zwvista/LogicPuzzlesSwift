//
//  GameObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/11/08.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum GridLineObject: Int {
    case empty, line, marker, forbidden
    init() {
        self = .empty
    }
}

// A dot can connect as many as 4 lines.
typealias GridDotObject = [GridLineObject]

class GridDots {
    var rows = 0
    var cols = 0
    var objArray = [GridDotObject]()
    
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
    }
    
    subscript(p: Position) -> GridDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
}
