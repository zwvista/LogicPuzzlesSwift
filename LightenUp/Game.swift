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

struct GameInstruction {
    var toadd = true
    var lightCells = Set<Position>()
    var lightbulbs = [Position]()
}

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
    
    mutating func setObject(p: Position, obj: GameObject) -> GameInstruction {
        var instruction = GameInstruction()
        
        func adjustedLightness(p: Position, tolighten: Bool, lightness: Int) -> Int {
            if tolighten {
                if lightness == 0 { instruction.lightCells.insert(p) }
                return lightness + 1
            } else if lightness > 0 {
                if lightness == 1 { instruction.lightCells.insert(p) }
                return lightness - 1
            } else {
                return lightness
            }
        }
        
        func adjustLightness(tolighten: Bool) {
            for os in offset {
                var p2 = p + os
                loop: while isValid(p2) {
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
            instruction.toadd = false
            instruction.lightbulbs.append(p)
            self[p] = .empty(lightness: adjustedLightness(p: p, tolighten: false, lightness: lightness))
            adjustLightness(tolighten: false)
        case .lightBulb:
            guard case .empty(let lightness) = self[p] else {break}
            instruction.lightbulbs.append(p)
            self[p] = .lightBulb(lightness: adjustedLightness(p: p, tolighten: true, lightness: lightness))
            adjustLightness(tolighten: true)
        }

        return instruction
    }
    
    mutating func toggleObject(p: Position) -> GameInstruction {
        switch self[p] {
        case .empty:
            return setObject(p: p, obj: .lightBulb(lightness: 0))
        case .lightBulb:
            return setObject(p: p, obj: .empty(lightness: 0))
        default:
            return GameInstruction()
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
