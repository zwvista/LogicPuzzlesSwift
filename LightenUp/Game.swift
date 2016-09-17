//
//  Game.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/10.
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

let offset: [Position] = [
    Position(-1, 0),
    Position(0, 1),
    Position(1, 0),
    Position(0, -1),
];

struct GameState {
    let size: Position
    var objArray: [GameObject]
    
    init(size: Position) {
        self.size = size
        objArray = Array<GameObject>(repeating: GameObject(), count: size.row * size.col)
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
    
    func isValid(_ p: Position) -> Bool {
        return isValid(p.row, p.col)
    }
    func isValid(_ row: Int, _ col: Int) -> Bool {
        return row >= 0 && col >= 0 && row < size.row && col < size.col
    }
    
    mutating func setObject(_ p: Position, obj: GameObject) {
        func adjustedLightness(_ isLit: Bool, lightness: Int) -> Int {
            return isLit ? lightness + 1 : max(lightness - 1, 0)
        }
        func adjustLightness(_ isLit: Bool) {
            for os in offset {
                var p2 = p + os
                loop: while isValid(p2) {
                    switch self[p2] {
                    case .wall:
                        break loop
                    case .empty(var lightness):
                        lightness = adjustedLightness(isLit, lightness: lightness)
                    case .lightBulb(var lightness):
                        lightness = adjustedLightness(isLit, lightness: lightness)
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
            self[p] = .empty(lightness: adjustedLightness(false, lightness: lightness))
            adjustLightness(false)
        case .lightBulb:
            guard case .empty(let lightness) = self[p] else {break}
            self[p] = .lightBulb(lightness: adjustedLightness(true, lightness: lightness))
            adjustLightness(true)
        }
    }
    
    mutating func toggleObject(_ p: Position) {
        switch self[p] {
        case .empty:
            setObject(p, obj: .lightBulb(lightness: 0))
        case .lightBulb:
            setObject(p, obj: .empty(lightness: 0))
        default:
            break
        }
    }
    
    var isSolved: Bool {
        for r in 0..<size.row {
            for c in 0..<size.col {
                switch self[r, c] {
                case .empty(let lightness) where lightness == 0:
                    return false
                case .lightBulb(let lightness) where lightness > 1:
                    return false
                default:
                    break
                }
            }
        }
        return true
    }
}

class Game {
    var state: GameState
    var walls = [Position : Int]()
    
    func addWall(row: Int, col: Int, lightbulbs: Int){
        state[row, col] = .wall(lightbulbs: lightbulbs)
        walls[Position(row, col)] = lightbulbs
    }
    
    init() {
        state = GameState(size: Position(5, 5))
        addWall(row: 0, col: 2, lightbulbs: -1);
        addWall(row: 0, col: 4, lightbulbs: -1);
        addWall(row: 1, col: 3, lightbulbs: 4);
        addWall(row: 2, col: 2, lightbulbs: 4);
        addWall(row: 4, col: 1, lightbulbs: 0);
    }
}
