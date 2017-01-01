//
//  FenceItUpDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class FenceItUpDocument: GameDocument<FenceItUpGame, FenceItUpGameMove> {
    static var sharedInstance = FenceItUpDocument()
    
    override func saveMove(_ move: FenceItUpGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> FenceItUpGameMove? {
        return FenceItUpGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1, obj: GridLineObject(rawValue: rec.intValue2)!)
    }
}
