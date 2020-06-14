//
//  BattleShipsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BattleShipsDocument: GameDocument<BattleShipsGameMove> {
    static var sharedInstance = BattleShipsDocument()
    
    override func saveMove(_ move: BattleShipsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> BattleShipsGameMove? {
        return BattleShipsGameMove(p: Position(rec.row, rec.col), obj: BattleShipsObject(rawValue: rec.intValue1)!)
    }
}
