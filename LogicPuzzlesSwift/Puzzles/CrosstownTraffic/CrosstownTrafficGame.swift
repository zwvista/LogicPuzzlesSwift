//
//  CrosstownTrafficGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CrosstownTrafficGame: GridGame<CrosstownTrafficGameState> {
    static let offset = Position.Directions4
    static let PUZ_UNKNOWN = -1

    override func isValid(row: Int, col: Int) -> Bool {
        1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var pos2hint = [Position: Int]()

    init(layout: [String], delegate: CrosstownTrafficGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)

        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols where (r == 0 || r == rows - 1) != (c == 0 || c == cols - 1) {
                let ch = str[c]
                pos2hint[Position(r, c)] = ch.isNumber ? ch.toInt! : CrosstownTrafficGame.PUZ_UNKNOWN
            }
        }
        
        let state = CrosstownTrafficGameState(game: self)
        levelInitialized(state: state)
    }

}
