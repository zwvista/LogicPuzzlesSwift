//
//  TapAlikeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TapAlikeDocument: GameDocument<TapAlikeGameMove> {
    static var sharedInstance = TapAlikeDocument()
    
    override func saveMove(_ move: TapAlikeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TapAlikeGameMove {
        TapAlikeGameMove(p: Position(rec.row, rec.col), obj: TapAlikeObject.fromString(str: rec.strValue1!))
    }
}
