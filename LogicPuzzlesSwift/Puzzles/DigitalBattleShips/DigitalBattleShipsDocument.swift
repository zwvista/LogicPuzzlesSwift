//
//  DigitalBattleShipsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class DigitalBattleShipsDocument: GameDocument<DigitalBattleShipsGameMove> {
    static var sharedInstance = DigitalBattleShipsDocument()
    
    override func saveMove(_ move: DigitalBattleShipsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> DigitalBattleShipsGameMove {
        DigitalBattleShipsGameMove(p: Position(rec.row, rec.col), obj: DigitalBattleShipsObject(rawValue: rec.intValue1)!)
    }
}
