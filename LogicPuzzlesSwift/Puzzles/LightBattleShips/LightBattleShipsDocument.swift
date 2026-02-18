//
//  LightBattleShipsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightBattleShipsDocument: GameDocument<LightBattleShipsGameMove> {
    static var sharedInstance = LightBattleShipsDocument()
    
    override func saveMove(_ move: LightBattleShipsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LightBattleShipsGameMove {
        LightBattleShipsGameMove(p: Position(rec.row, rec.col), obj: LightBattleShipsObject(rawValue: rec.intValue1)!)
    }
}
