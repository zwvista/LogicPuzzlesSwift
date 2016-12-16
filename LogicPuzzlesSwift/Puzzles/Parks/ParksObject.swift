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
    case tree(state: AllowedObjectState)
    case marker
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .tree:
            return "tree"
        case .marker:
            return "marker"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> ParksObject {
        switch str {
        case "tree":
            return .tree(state: .normal)
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct ParksDots {
    var rows = 0
    var cols = 0
    var objArray = [[Bool]]()
    
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        objArray = Array<LoopyObject>(repeating: Array<Bool>(repeating: false, count: 4), count: rows * cols)
    }

    subscript(p: Position) -> LoopyObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LoopyObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
}

struct ParksGameMove {
    var p = Position()
    var obj = ParksObject()
}
