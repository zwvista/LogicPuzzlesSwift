//
//  ProductSentinelsGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ProductSentinelsGame: GridGame<ProductSentinelsGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var pos2hint = [Position: Int]()
    
    init(layout: [String], delegate: ProductSentinelsGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s = str[c * 2...c * 2 + 1]
                guard s != "  " else {continue}
                let n = s.toInt()!
                pos2hint[p] = n
            }
        }
        
        let state = ProductSentinelsGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    func switchObject(move: inout ProductSentinelsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout ProductSentinelsGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
