//
//  TatamiGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TatamiGame: GridGame<TatamiGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: TatamiDots!
    var objArray = [Character]()
    
    init(layout: [String], delegate: TatamiGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2, layout[0].length / 2)
        dots = TatamiDots(rows: rows + 1, cols: cols + 1)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows + 1 {
            var str = layout[2 * r]
            for c in 0..<cols {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    dots[r, c][1] = .line
                    dots[r, c + 1][3] = .line
                }
            }
            guard r < rows else {break}
            str = layout[2 * r + 1]
            for c in 0..<cols + 1 {
                let ch = str[2 * c]
                if ch == "|" {
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                }
                guard c < cols else {continue}
                let ch2 = str[2 * c + 1]
                if case "0"..."9" = ch2 {
                    self[r, c] = ch2
                }
            }
        }
        var rng = Set<Position>()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                rng.insert(p)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in 0..<4 {
                    if dots[p + TatamiGame.offset2[i]][TatamiGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + TatamiGame.offset[i]]!)
                    }
                }
            }
        }
        while !rng.isEmpty {
            let node = pos2node[rng.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            let area = rng.filter({p in nodesExplored.contains(p.description)})
            let n = areas.count
            for p in area {
                pos2area[p] = n
            }
            areas.append(area)
            rng.subtract(area)
        }
        
        let state = TatamiGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout TatamiGameMove, f: (inout TatamiGameState, inout TatamiGameMove) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        var state = self.state.copy()
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    subscript(p: Position) -> Character {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Character {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func switchObject(move: inout TatamiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout TatamiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
