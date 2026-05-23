//
//  KakuroGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class KakuroGame: GridGame<KakuroGameState> {
    static let offset = Position.Directions4

    var pos2horzHint = [Position: Int]()
    var pos2vertHint = [Position: Int]()
    var pos2num = [Position: Int]()

    init(layout: [String], delegate: KakuroGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 4)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s1 = str[c * 4..<c * 4 + 2]
                let s2 = str[c * 4 + 2..<c * 4 + 4]
                if s1[0] == " " {
                    pos2num[p] = 0
                } else {
                    if s1 != "00" { pos2vertHint[p] = s1.toInt()! }
                    if s2 != "00" { pos2horzHint[p] = s2.toInt()! }
                }
            }
        }

        let state = KakuroGameState(game: self)
        levelInitialized(state: state)
    }
    
}
