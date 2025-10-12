//
//  TierraDelFuegoDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TierraDelFuegoDocument: GameDocument<TierraDelFuegoGameMove> {
    static var sharedInstance = TierraDelFuegoDocument()
    
    override func saveMove(_ move: TierraDelFuegoGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TierraDelFuegoGameMove {
        TierraDelFuegoGameMove(p: Position(rec.row, rec.col), obj: TierraDelFuegoObject.fromString(str: rec.strValue1!))
    }
}
