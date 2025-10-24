//
//  CalcudokuGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CalcudokuGame: GridGame<CalcudokuGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    var objArray = [Character]()
    var pos2hint = [Position: CalcudokuHint]()
    
    init(layout: [String], delegate: CalcudokuGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 4)
        dots = GridDots(rows: rows + 1, cols: cols + 1)
        objArray = Array<Character>(repeating: " ", count: rows * cols)

        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let (ch1, s, ch2) = (str[c * 4], str[c * 4 + 1...c * 4 + 2], str[c * 4 + 3])
                self[p] = ch1
                pos2node[p] = g.addNode(p.description)
                guard s != "  " else {continue}
                pos2hint[Position(r, c)] = CalcudokuHint(op: ch2, result: s.toInt()!)
            }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = self[p]
                for os in CalcudokuGame.offset {
                    let p2 = p + os
                    if isValid(p: p2) && self[p2] == ch {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                    }
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let n = areas.count
            let ch = self[area[0]]
            for p in area {
                pos2area[p] = n
                for i in 0..<4 {
                    let p2 = p + CalcudokuGame.offset[i]
                    let ch2 = !isValid(p: p2) ? "." : self[p2]
                    if ch2 != ch {
                        dots[p + CalcudokuGame.offset2[i]][CalcudokuGame.dirs[i]] = .line
                    }
                }
            }
            areas.append(area)
        }
        for r in 0..<rows {
            dots[r, 0][2] = .line
            dots[r + 1, 0][0] = .line
            dots[r, cols][2] = .line
            dots[r + 1, cols][0] = .line
        }
        for c in 0..<cols {
            dots[0, c][1] = .line
            dots[0, c + 1][3] = .line
            dots[rows, c][1] = .line
            dots[rows, c + 1][3] = .line
        }

        let state = CalcudokuGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
