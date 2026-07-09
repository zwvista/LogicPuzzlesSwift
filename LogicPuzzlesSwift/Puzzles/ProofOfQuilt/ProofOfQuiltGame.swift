//
//  ProofOfQuiltGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ProofOfQuiltGame: GridGame<ProofOfQuiltGameState> {
    static let offset = Position.Directions4

    var pos2hint = [Position: Int]()
    var patterns = [[Position: ProofOfQuiltObject]]()
    var allPositions = Set<Position>()
    var objArray = [ProofOfQuiltObject]()
    subscript(p: Position) -> ProofOfQuiltObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ProofOfQuiltObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }

    init(layout: [String], delegate: ProofOfQuiltGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<ProofOfQuiltObject>(repeating: .empty, count: rows * cols)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch != " " {
                    allPositions.insert(p)
                } else {
                    self[p] = .filled
                    if ch != "W" { pos2hint[p] = ch.toInt! }
                }
            }
        }
        for i in 2...rows {
            for j in 1..<i {
                let k = i - j
                var pattern = [Position: ProofOfQuiltObject]()
                for dr in 0..<i {
                    let m1: Int, m2: Int
                    let o1: ProofOfQuiltObject, o2: ProofOfQuiltObject
                    if (dr < min(j, k)) {
                        m1 = j - 1 - dr
                        m2 = j + dr
                        o1 = .triangleA
                        o2 = .triangleB
                    } else if (dr < j) {
                        m1 = j - 1 - dr
                        m2 = i - 1 - dr + k
                        o1 = .triangleA
                        o2 = .triangleD
                    } else if (dr < max(j, k)) {
                        m1 = dr - j
                        m2 = j + dr
                        o1 = .triangleC
                        o2 = .triangleB
                    } else {
                        m1 = dr - j
                        m2 = i - 1 - dr + k
                        o1 = .triangleC
                        o2 = .triangleD
                    }
                    for dc in 0..<i {
                        let p = Position(dr, dc)
                        if (dc == m1) {
                            pattern[p] = o1
                        } else if (dc > m1 && dc < m2) {
                            pattern[p] = .empty
                        } else if (dc == m2) {
                            pattern[p] = o2
                        }
                    }
                }
                patterns.append(pattern)
            }
        }

        let state = ProofOfQuiltGameState(game: self)
        levelInitialized(state: state)
    }
    
}
