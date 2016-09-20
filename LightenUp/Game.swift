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
    func gameUpdated(_ sender: Game)
    func gameSolved(_ sender: Game)
}

class Game {
    private var stateIndex = 0
    private var states = [GameState]()
    private var state: GameState {return states[stateIndex]}
    private var moves = [GameMove]()
    private var move: GameMove {return moves[stateIndex - 1]}
    
    private(set) var walls = [Position: Int]()
    private(set) weak var delegate: GameDelegate?
    var size: Position {return state.size}
    var isSolved: Bool {return state.isSolved}
    var canUndo: Bool {return stateIndex > 0}
    var canRedo: Bool {return stateIndex < states.count - 1}
    var moveIndex: Int {return stateIndex}
    var moveCount: Int {return states.count - 1}
    var movesAsString: String? {
        return moves.isEmpty ? nil : moves.map({m in "\(m.p)"}).joined(separator: "\n")
    }
    
    private func gameUpdated() {
        delegate?.gameUpdated(self)
        if isSolved { delegate?.gameSolved(self) }
    }
    
    init(layout: [String], delegate: GameDelegate? = nil) {
        self.delegate = delegate
        
        var state = GameState(rows: layout.count, cols: layout[0].characters.count)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            state[row, col] = .wall(lightbulbs: lightbulbs)
            walls[Position(row, col)] = lightbulbs
        }
        
        for r in 0 ..< state.size.row {
            let str = layout[r]
            for c in 0 ..< state.size.col {
                let ch = str[str.index(str.startIndex, offsetBy: c)]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0" ... "9":
                    addWall(row: r, col: c, lightbulbs: Int(String(ch))!)
                default:
                    break
                }
            }
        }
        
        states.append(state)
        gameUpdated()
   }
    
    func toggleObject(p: Position) -> (Bool, GameMove) {
        if canRedo {
            states.removeSubrange((stateIndex + 1) ..< states.count)
            moves.removeSubrange(stateIndex ..< moves.count)
        }
        
        // copy a state
        var state = self.state
        let (changed, move) = state.toggleObject(p: p)
        
        if changed {
            states.append(state)
            stateIndex += 1
            moves.append(move)
            gameUpdated()
        }

        return (changed, move)
    }
    
    func undo() -> GameMove {
        guard canUndo else {return GameMove()}
        var move = self.move
        move.toadd = !move.toadd
        stateIndex -= 1
        gameUpdated()
        return move
    }
    
    func redo() -> GameMove {
        guard canRedo else {return GameMove()}
        stateIndex += 1
        gameUpdated()
        return move
    }
    
    static func movesFrom(str: String) -> [Position] {
        return str == "" ? [Position]() :
            str.components(separatedBy: "\n").map { m in
                let row = Int(String(m[m.index(m.startIndex, offsetBy: 1)]))!
                let col = Int(String(m[m.index(m.startIndex, offsetBy: 3)]))!
                return Position(row, col)
            }
    }

}
