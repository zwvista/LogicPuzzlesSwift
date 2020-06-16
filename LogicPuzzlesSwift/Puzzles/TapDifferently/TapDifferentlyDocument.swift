//
//  TapDifferentlyDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TapDifferentlyDocument: GameDocument<TapDifferentlyGameMove> {
    static var sharedInstance = TapDifferentlyDocument()
    
    override func saveMove(_ move: TapDifferentlyGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TapDifferentlyGameMove? {
        TapDifferentlyGameMove(p: Position(rec.row, rec.col), obj: TapDifferentlyObject.fromString(str: rec.strValue1!))
    }
}
