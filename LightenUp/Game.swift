//
//  Game.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameDelegate {
    func gameSolved(_ sender: Game)
}

class Game {
    private var currentIndex = 0
    private var states = [GameState]()
    private var state: GameState {return states[currentIndex]}
    private var instructions = [GameInstruction]()
    private var instruction: GameInstruction {return instructions[currentIndex - 1]}
    
    var walls = [Position: Int]()
    var delegate: GameDelegate?
    var size: Position {return state.size}
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return currentIndex > 0}
    var canRedo: Bool {return currentIndex < states.count - 1}
    
    init(strs: [String]) {
        var state = GameState(rows: strs.count, cols: strs[0].characters.count)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            state[row, col] = .wall(lightbulbs: lightbulbs)
            walls[Position(row, col)] = lightbulbs
        }
        
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
        
        states.append(state)
    }
    
    func toggleObject(p: Position) -> GameInstruction {
        if canRedo {
            states.removeSubrange((currentIndex + 1) ..< states.count)
            instructions.removeSubrange(currentIndex ..< instructions.count)
        }
        
        // copy a state
        var state = self.state
        let instruction = state.toggleObject(p: p)
        
        states.append(state)
        currentIndex += 1
        if isSolved { delegate?.gameSolved(self) }
        
        instructions.append(instruction)
        return instruction
    }
    
    func undo() -> GameInstruction {
        guard canUndo else {return GameInstruction()}
        var instruction = self.instruction
        instruction.toadd = !instruction.toadd
        currentIndex -= 1
        return instruction
    }
    
    func redo() -> GameInstruction {
        guard canRedo else {return GameInstruction()}
        currentIndex += 1
        return instruction
    }
}
