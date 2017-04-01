//
//  OrchardsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum OrchardsObject {
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
    static func fromString(str: String) -> OrchardsObject {
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

class OrchardsDots {
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

struct OrchardsGameMove {
    var p = Position()
    var obj = OrchardsObject()
}
