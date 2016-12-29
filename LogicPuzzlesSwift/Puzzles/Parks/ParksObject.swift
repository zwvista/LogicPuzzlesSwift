//
//  ParksObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ParksObject {
    case empty
    case forbidden
    case marker
    case tree(state: AllowedObjectState)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .marker:
            return "marker"
        case .tree:
            return "tree"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ParksObject {
        switch str {
        case "marker":
            return .marker
        case "tree":
            return .tree(state: .normal)
        default:
            return .empty
        }
    }
}

class ParksDots {
    var rows = 0
    var cols = 0
    var objArray = [GridDotObject]()
    
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
    }
    
    subscript(p: Position, dir: Int) -> GridLineObject {
        get {
            return self[p.row, p.col, dir]
        }
        set(newValue) {
            self[p.row, p.col, dir] = newValue
        }
    }
    subscript(row: Int, col: Int, dir: Int) -> GridLineObject {
        get {
            return objArray[row * cols + col][dir]
        }
        set(newValue) {
            objArray[row * cols + col][dir] = newValue
        }
    }
}

struct ParksGameMove {
    var p = Position()
    var obj = ParksObject()
}
