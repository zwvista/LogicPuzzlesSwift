//
//  MineShipsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MineShipsDocument: GameDocument<MineShipsGameMove> {
    static var sharedInstance = MineShipsDocument()
    
    override func saveMove(_ move: MineShipsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> MineShipsGameMove {
        MineShipsGameMove(p: Position(rec.row, rec.col), obj: MineShipsObject.fromString(str: rec.strValue1!))
    }
}
