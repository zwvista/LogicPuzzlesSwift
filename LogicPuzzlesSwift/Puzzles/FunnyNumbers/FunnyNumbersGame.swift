//
//  FunnyNumbersGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class FunnyNumbersGame: GridGame<FunnyNumbersGameState> {
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
    var row2hint = [Int]()
    var col2hint = [Int]()
    var objArray = [Int]()

    init(layout: [String], delegate: FunnyNumbersGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 - 1, layout[0].length / 2 - 1)
        dots = GridDots(rows: rows + 1, cols: cols + 1)
        row2hint = Array<Int>(repeating: 0, count: rows)
        col2hint = Array<Int>(repeating: 0, count: cols)
        objArray = Array<Int>(repeating: 0, count: rows * cols)

        for r in 0..<rows + 1 {
            var str = layout[2 * r]
            for c in 0..<cols {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    dots[r, c][1] = .line
                    dots[r, c + 1][3] = .line
                }
            }
            str = layout[2 * r + 1]
            if r < rows {
                for c in 0..<cols + 1 {
                    let ch = str[2 * c]
                    if ch == "|" {
                        dots[r, c][2] = .line
                        dots[r + 1, c][0] = .line
                    }
                    guard c < cols else {continue}
                    let ch2 = str[2 * c + 1]
                    if ch2.isNumber {
                        self[r, c] = ch2.toInt!
                    }
                }
                let s = str[2 * cols + 1...2 * cols + 2]
                row2hint[r] = s == "  " ? 0 : s.toInt()!
            } else {
                for c in 0..<cols {
                    let s = str[2 * c...2 * c + 1]
                    col2hint[c] = s == "  " ? 0 : s.toInt()!
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
                    if dots[p + FunnyNumbersGame.offset2[i]][FunnyNumbersGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + FunnyNumbersGame.offset[i]]!)
                    }
                }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let n = areas.count
            for p in area {
                pos2area[p] = n
            }
            areas.append(area)
        }
        
        let state = FunnyNumbersGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> Int {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Int {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
}
