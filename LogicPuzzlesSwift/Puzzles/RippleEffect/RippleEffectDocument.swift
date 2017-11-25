//
//  RippleEffectDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class RippleEffectDocument: GameDocument<RippleEffectGame, RippleEffectGameMove> {
    static var sharedInstance = RippleEffectDocument()
    
    override func saveMove(_ move: RippleEffectGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> RippleEffectGameMove? {
        return RippleEffectGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
