//
//  GameState.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum GameObject {
    case empty(lightness: Int)
    case lightBulb(lightness: Int)
    case wall(lightbulbs: Int)
    init() {
        self = .empty(lightness: 0)
    }
}

let offset = [
    Position(-1, 0),
    Position(0, 1),
    Position(1, 0),
    Position(0, -1),
];

struct GameMove {
    var p = Position()
    var obj = GameObject()
    var toadd = true
    var lightCells = Set<Position>()
    var lightbulbs = [Position]()
}

struct GameState {
    let size: Position
    var objArray: [GameObject]
    
    init(rows: Int, cols: Int) {
        self.size = Position(rows, cols)
        objArray = Array<GameObject>(repeating: GameObject(), count: rows * cols)
    }
    
    subscript(p: Position) -> GameObject {
        get {
            return objArray[p.row * size.col + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GameObject {
        get {
            return objArray[row * size.col + col]
        }
        set(newValue) {
            objArray[row * size.col + col] = newValue
        }
    }
    
    func isValid(p: Position) -> Bool {
        return isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < size.row && col < size.col
    }
    
    mutating func setObject(p: Position, obj: GameObject) -> (Bool, GameMove) {
        var changed = false
        var move = GameMove()
        
        func adjustedLightness(p: Position, tolighten: Bool, lightness: Int) -> Int {
            if tolighten {
                if lightness == 0 { move.lightCells.insert(p) }
                return lightness + 1
            } else if lightness > 0 {
                if lightness == 1 { move.lightCells.insert(p) }
                return lightness - 1
            } else {
                return lightness
            }
        }
        
        func adjustLightness(tolighten: Bool) {
            for os in offset {
                var p2 = p + os
                loop: while isValid(p: p2) {
                    switch self[p2] {
                    case .wall:
                        break loop
                    case .empty(let lightness):
                        self[p2] = .empty(lightness: adjustedLightness(p: p2, tolighten: tolighten, lightness: lightness))
                    case .lightBulb(let lightness):
                        self[p2] = .lightBulb(lightness: adjustedLightness(p: p2, tolighten: tolighten, lightness: lightness))
                    }
                    p2 += os
                }
            }
        }
        
        switch obj {
        case .wall:
            self[p] = obj
        case .empty:
            guard case .lightBulb(let lightness) = self[p] else {break}
            changed = true
            move.p = p; move.obj = obj
            move.toadd = false
            move.lightbulbs.append(p)
            self[p] = .empty(lightness: adjustedLightness(p: p, tolighten: false, lightness: lightness))
            adjustLightness(tolighten: false)
        case .lightBulb:
            guard case .empty(let lightness) = self[p] else {break}
            changed = true
            move.p = p; move.obj = obj
            move.lightbulbs.append(p)
            self[p] = .lightBulb(lightness: adjustedLightness(p: p, tolighten: true, lightness: lightness))
            adjustLightness(tolighten: true)
        }
        
        return (changed, move)
    }
    
    mutating func toggleObject(p: Position) -> (Bool, GameMove) {
        defer { updateIsSolved() }
        switch self[p] {
        case .empty:
            return setObject(p: p, obj: .lightBulb(lightness: 0))
        case .lightBulb:
            return setObject(p: p, obj: .empty(lightness: 0))
        default:
            return (false, GameMove())
        }
    }
    
    var isSolved = false
    
    mutating func updateIsSolved() {
        isSolved = {
            for r in 0 ..< size.row {
                for c in 0 ..< size.col {
                    let p = Position(r, c)
                    switch self[r, c] {
                    case .empty(let lightness) where lightness == 0:
                        return false
                    case .lightBulb(let lightness) where lightness > 1:
                        return false
                    case .wall(let lightbulbs) where lightbulbs >= 0:
                        var n = 0
                        for os in offset {
                            let p2 = p + os
                            guard isValid(p: p2) else {continue}
                            if case .lightBulb = self[p2] {
                                n += 1
                            }
                        }
                        if n != lightbulbs {return false}
                    default:
                        break
                    }
                }
            }
            return true
        }()
    }
}
