//
//  ParksGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ParksGame: CellsGame<ParksGameViewController, ParksGameMove, ParksGameState>, GameBase {
    static var gameID = "Parks"
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ];
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ];
    static let dirs = [1, 0, 3, 2]

    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: ParksDots!
    
    init(layout: [String], delegate: ParksGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2, layout[0].length / 2)
        dots = ParksDots(rows: rows, cols: cols)
        
        for r in 0..<rows + 1 {
            var str = layout[2 * r]
            for c in 0..<cols {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    dots[r, c][1] = true
                    dots[r, c + 1][3] = true
                }
            }
            guard r < rows else {break}
            str = layout[2 * r + 1]
            for c in 0..<cols + 1 {
                let ch = str[2 * c]
                if ch == "|" {
                    dots[r, c][2] = true
                    dots[r + 1, c][0] = true
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
                pos2node[p] = g.addNode(label: p.description)
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
            rng = rng.intersection(area)
        }
        
        let state = ParksGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout ParksGameMove, f: (inout ParksGameState, inout ParksGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout ParksGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout ParksGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}