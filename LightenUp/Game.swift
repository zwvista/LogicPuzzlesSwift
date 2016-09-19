//
//  Game.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc
protocol GameDelegate: class {
    func gameStateUpdated(_ sender: Game)
    func gameSolved(_ sender: Game)
}

class Game {
    private var stateIndex = 0
    private var states = [GameState]()
    private var state: GameState {return states[stateIndex]}
    private var instructions = [GameInstruction]()
    private var instruction: GameInstruction {return instructions[stateIndex - 1]}
    
    var walls = [Position: Int]()
    weak var delegate: GameDelegate?
    var size: Position {return state.size}
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    
    init(strs: [String], delegate: GameDelegate? = nil) {
        self.delegate = delegate
        
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
        delegate?.gameStateUpdated(self)
    }
    
    func toggleObject(p: Position) -> GameInstruction {
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            instructions.removeSubrange(stateIndex ..< instructions.count)
        }
        
        // copy a state
        var state = self.state
        let instruction = state.toggleObject(p: p)
        
        states.append(state)
        stateIndex += 1
        delegate?.gameStateUpdated(self)
        if isSolved { delegate?.gameSolved(self) }
        
        instructions.append(instruction)
        return instruction
    }
    
    func undo() -> GameInstruction {
        guard canUndo else {return GameInstruction()}
        var instruction = self.instruction
        instruction.toadd = !instruction.toadd
        stateIndex -= 1
        delegate?.gameStateUpdated(self)
        return instruction
    }
    
    func redo() -> GameInstruction {
        guard canRedo else {return GameInstruction()}
        stateIndex += 1
        delegate?.gameStateUpdated(self)
        return instruction
    }
}
