//
//  MirrorsExtendedGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MirrorsExtendedGame: GridGame<MirrorsExtendedGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]
    static let offset3 = Position.Square2x2Offset
    static let PUZ_UNKNOWN = -1

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    var letter2laser = [Character: MirrorsExtendedLaser]()

    init(layout: [String], delegate: MirrorsExtendedGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2 + 1, layout[0].length / 2)
        dots = GridDots(rows: rows + 1, cols: cols + 1)

        for r in 1..<rows {
            var str = layout[2 * r - 1]
            for c in 1..<cols - 1 {
                let ch = str[2 * c + 1]
                if ch == "-" {
                    dots[r, c][1] = .line
                    dots[r, c + 1][3] = .line
                }
            }
            if r == rows {break}
            str = layout[2 * r]
            for c in 1..<cols {
                let ch = str[2 * c]
                if ch == "|" {
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
            }
        }
        for r in 1..<rows - 1 {
            for c in 1..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    if dots[p + MirrorsExtendedGame.offset2[i]][MirrorsExtendedGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + MirrorsExtendedGame.offset[i]]!)
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

        func f(r: Int, c: Int, d: Int) {
            let p = Position(r, c)
            let str = layout[2 * r]
            let c2 = 2 * c + (c == cols - 1 ? 1 : 0)
            let (ch1, ch2) = (str[c2], str[c2 + 1])
            guard ch1 != " " else {return}
            let n = ch2.isNumber ? ch2.toInt! : Int(ch2.asciiValue!) - Int(Character("A").asciiValue!) + 10
            letter2laser[ch1, default: MirrorsExtendedLaser(n: n)].dots.append(MirrorsExtendedLaserDot(p: p, dir: d))
        }
        for i in 0..<rows {
            f(r: 0, c: i, d: 2)
            f(r: rows - 1, c: i, d: 0)
            f(r: i, c: 0, d: 1)
            f(r: i, c: cols - 1, d: 3)
        }
        
        let state = MirrorsExtendedGameState(game: self)
        levelInitialized(state: state)
    }
}
