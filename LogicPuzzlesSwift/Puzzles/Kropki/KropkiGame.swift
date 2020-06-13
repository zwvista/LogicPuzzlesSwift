//
//  KropkiGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KropkiGame: GridGame<KropkiGameViewController> {
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

    var pos2horzHint = [Position: KropkiHint]()
    var pos2vertHint = [Position: KropkiHint]()
    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    let bordered: Bool

    init(layout: [String], bordered: Bool, delegate: KropkiGameViewController? = nil) {
        self.bordered = bordered

        super.init(delegate: delegate)
        
        size = Position(bordered ? layout.count / 4 : layout.count / 2 + 1, layout[0].length)

        for r in 0..<rows * 2 - 1 {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r / 2, c)
                let ch = str[c]
                let kh: KropkiHint = ch == "W" ? .consecutive :
                    ch == "B" ? .twice : .none
                // Cannot assign through subscript:
                // result of conditional operator '? :' is never mutable
                // (r % 2 == 0 ? pos2horzHint : pos2vertHint)[p] = kh
                if r % 2 == 0 {
                    pos2horzHint[p] = kh
                } else {
                    pos2vertHint[p] = kh
                }
            }
        }
        if bordered {
            dots = GridDots(rows: rows + 1, cols: cols + 1)
            for r in 0..<rows + 1 {
                var str = layout[rows * 2 - 1 + 2 * r]
                for c in 0..<cols {
                    let ch = str[2 * c + 1]
                    if ch == "-" {
                        dots[r, c][1] = .line
                        dots[r, c + 1][3] = .line
                    }
                }
                guard r < rows else {break}
                str = layout[rows * 2 - 1 + 2 * r + 1]
                for c in 0..<cols + 1 {
                    let ch = str[2 * c]
                    if ch == "|" {
                        dots[r, c][2] = .line
                        dots[r + 1, c][0] = .line
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
                        if dots[p + KropkiGame.offset2[i]][KropkiGame.dirs[i]] != .line {
                            g.addEdge(pos2node[p]!, neighbor: pos2node[p + KropkiGame.offset[i]]!)
                        }
                    }
                }
            }
            while !rng.isEmpty {
                let node = pos2node[rng.first!]!
                let nodesExplored = breadthFirstSearch(g, source: node)
                let area = [Position](rng.filter{nodesExplored.contains($0.description)})
                let n = areas.count
                for p in area {
                    pos2area[p] = n
                }
                areas.append(area)
                rng.subtract(area)
            }
        }

        let state = KropkiGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout KropkiGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
