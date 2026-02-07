//
//  ShopAndGasGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ShopAndGasGame: GridGame<ShopAndGasGameState> {
    static let offset = Position.Directions4
    static let PUZ_HOME: Character = "H"
    static let PUZ_SHOP: Character = "S"
    static let PUZ_GAS: Character = "G"

    var objArray = [Character]()
    var home = Position.Zero
    subscript(p: Position) -> Character {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> Character {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    init(layout: [String], delegate: ShopAndGasGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        objArray = Array<Character>(repeating: " ", count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                let p = Position(r, c)
                self[p] = ch
                if ch == ShopAndGasGame.PUZ_HOME {
                    home = p
                }
            }
        }
        
        let state = ShopAndGasGameState(game: self)
        levelInitialized(state: state)
    }
    
}
