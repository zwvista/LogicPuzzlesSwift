//
//  AbstractPaintingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbstractPaintingGame: GridGame<AbstractPaintingGameViewController> {
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

    var row2hint = [Int]()
    var col2hint = [Int]()
    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    
    init(layout: [String], delegate: AbstractPaintingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 - 1, layout[0].length /  2 - 1)
        dots = GridDots(rows: rows + 1, cols: cols + 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        
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
                    if dots[p + AbstractPaintingGame.offset2[i]][AbstractPaintingGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + AbstractPaintingGame.offset[i]]!)
                    }
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            let n = areas.count
            for p in area {
                pos2area[p] = n
            }
            areas.append(area)
        }
        
        for r in 0..<rows {
            let ch = layout[2 * r + 1][2 * cols + 1]
            if case "1"..."9" = ch {
                row2hint[r] = ch.toInt!
            } else {
                row2hint[r] = -1
            }
        }
        for c in 0..<cols {
            let ch = layout[2 * rows + 1][2 * c + 1]
            if case "1"..."9" = ch {
                col2hint[c] = ch.toInt!
            } else {
                col2hint[c] = -1
            }
        }
        
        let state = AbstractPaintingGameState(game: self)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout AbstractPaintingGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.switchObject(move: &move) })
    }
    
    func setObject(move: inout AbstractPaintingGameMove) -> Bool {
        changeObject(move: &move, f: { state, move in state.setObject(move: &move) })
    }
    
}
