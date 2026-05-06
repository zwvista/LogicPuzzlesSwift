//
//  AbstractMirrorPaintingGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class AbstractMirrorPaintingGame: GridGame<AbstractMirrorPaintingGameState> {
    static let offset = Position.Directions4
    static let offset2 = [
        Position(0, 0),
        Position(1, 1),
        Position(1, 1),
        Position(0, 0),
    ]
    static let dirs = [1, 0, 3, 2]

    var pos2hint = [Position: Int]()
    var areas = [[Position]]()
    var pos2area = [Position: Int]()
    var dots: GridDots!
    var mirrors = [AbstractMirrorPaintingMirror]()

    init(layout: [String], delegate: AbstractMirrorPaintingGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count / 2, layout[0].length /  2)
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
                let ch = str[2 * c]
                if ch == "|" {
                    dots[r, c][2] = .line
                    dots[r + 1, c][0] = .line
                }
                guard c < cols else {break}
                let ch2 = str[2 * c + 1]
                guard ch2.isNumber else {continue}
                pos2hint[Position(r, c)] = ch2.toInt!
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
                    if dots[p + AbstractMirrorPaintingGame.offset2[i]][AbstractMirrorPaintingGame.dirs[i]] != .line {
                        g.addEdge(pos2node[p]!, neighbor: pos2node[p + AbstractMirrorPaintingGame.offset[i]]!)
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
        for r in 0..<rows {
            for c in 0..<cols {
                let p1 = Position(r, c)
                let areaId1 = pos2area[p1]!
                for i in [1, 2] {
                    let p2 = p1 + AbstractMirrorPaintingGame.offset[i]
                    guard let areaId2 = pos2area[p2], areaId1 != areaId2 else {continue}
                    if areaId1 < areaId2 {
                        mirrors.append(AbstractMirrorPaintingMirror(p1: p1, p2: p2, areaId1: areaId1, areaId2: areaId2))
                    } else {
                        mirrors.append(AbstractMirrorPaintingMirror(p1: p2, p2: p1, areaId1: areaId2, areaId2: areaId1))
                    }
                }
            }
        }
        let state = AbstractMirrorPaintingGameState(game: self)
        levelInitialized(state: state)
    }
    
}
