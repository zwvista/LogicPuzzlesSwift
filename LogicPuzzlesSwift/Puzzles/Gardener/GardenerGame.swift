//
//  GardenerGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class GardenerGame: GridGame<GardenerGameViewController> {
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
    var dots: GridDots!
    var pos2hint = [Position: (Int, Int)]()
    var pos2area = [Position: Int]()

    init(layout: [String], delegate: GardenerGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2, layout[0].length / 2)
        dots = GridDots(rows: rows + 1, cols: cols + 1)
        
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
                var ch = str[2 * c]
                if ch == "|" {
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                }
                guard c < cols else {break}
                ch = str[2 * c + 1]
                if ch != " " {
                    pos2hint[Position(r, c)] = (ch.toInt!, -1)
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                for i in 0..<4 {
                    if dots[p + GardenerGame.offset2[i]][GardenerGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + GardenerGame.offset[i]]!)
                    }
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter{nodesExplored.contains($0.0.description)}.map{$0.0}
            pos2node = pos2node.filter{!nodesExplored.contains($0.0.description)}
            let n = areas.count
            for p in area {
                pos2area[p] = n
            }
            areas.append(area)
        }
        for p in pos2hint.keys {
            pos2hint[p]!.1 = pos2area[p]!
        }
        
        let state = GardenerGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout GardenerGameMove, f: (inout GardenerGameState, inout GardenerGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout GardenerGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout GardenerGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
