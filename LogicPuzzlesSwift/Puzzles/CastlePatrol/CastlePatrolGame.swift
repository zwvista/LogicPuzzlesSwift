//
//  CastlePatrolGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CastlePatrolGame: GridGame<CastlePatrolGameState> {
    static let offset = Position.Directions4

    var pos2obj = [Position: CastlePatrolObject]()
    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: CastlePatrolGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let (ch1, ch2) = (str[c * 2], str[c * 2 + 1])
                let p = Position(r, c)
                func f(obj: CastlePatrolObject) {
                    pos2obj[p] = obj
                    pos2hint[p] = ch1.isNumber ? ch1.toInt! : Int(ch1.asciiValue!) - Int(Character("A").asciiValue!) + 10
                }
                switch ch2 {
                case ".":
                    f(obj: .emptyHint)
                case "W":
                    f(obj: .wallHint)
                default:
                    break
                }
            }
        }
        
        let state = CastlePatrolGameState(game: self)
        levelInitialized(state: state)
    }
}
