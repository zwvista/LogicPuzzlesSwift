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

let offset = [
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
    }
}

protocol GameDelegate {
    func gameSolved(_ sender: Game)
}

class Game {
    private var state: GameState
    var isSolved = false
    var walls = [Position: Int]()
    var delegate: GameDelegate?
    
    func toggleObject(p: Position) -> GameInstruction {
        let instruction = state.toggleObject(p: p)
        isSolved = state.isSolved
        if isSolved { delegate?.gameSolved(self) }
        return instruction
    }
    
    init(strs: [String]) {
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            state[row, col] = .wall(lightbulbs: lightbulbs)
            walls[Position(row, col)] = lightbulbs
        }
        
        state = GameState(rows: strs.count, cols: strs[0].characters.count)
        
        for r in 0..<state.size.row {
            let str = strs[r]
            for c in 0..<state.size.col {
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0"..."9":
                    addWall(row: r, col: c, lightbulbs: Int(String(ch))!)
                default:
                    break
                }
            }
        }
    }
}
