//
//  TurnTwiceGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TurnTwiceGame: GridGame<TurnTwiceGameState> {
    static let offset = Position.Directions4

    var objArray = [TurnTwiceObject]()
    // two signposts and the shortest path between them
    var paths = [(Position, Position, [Position])]()

    init(layout: [String], delegate: TurnTwiceGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<TurnTwiceObject>(repeating: .empty, count: rows * cols)
        
        var signposts = [Position]()
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let ch = str[c]
                if ch == "S" {
                    self[p] = .signpost(state: .normal)
                    signposts.append(p)
                }
            }
        }
        
        let os0 = Position.Zero
        let sz = signposts.count
        for i in 0..<sz - 1 {
            let p1 = signposts[i]
            for j in i + 1..<sz {
                let p2 = signposts[j]
                let sz2 = p1.row == p2.row || p1.col == p2.col ? 1 : 2
                for k in 0..<sz2 {
                    var path = [Position]()
                    if ({
                        var p = p1
                        while true {
                            let os1 = Position((p2.row - p.row).signum(), 0)
                            let os2 = Position(0, (p2.col - p.col).signum())
                            let os = k == 0 && os1 != os0 || k == 1 && os2 == os0 ? os1 : os2
                            p += os
                            if p == p2 { return true }
                            if case .empty = self[p] {
                                path.append(p)
                            } else {
                                return false
                            }
                        }
                    }()) {
                        paths.append((p1, p2, path))
                    }
                }
            }
        }

        let state = TurnTwiceGameState(game: self)
        levelInitialized(state: state)
    }
    
    subscript(p: Position) -> TurnTwiceObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TurnTwiceObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
}
