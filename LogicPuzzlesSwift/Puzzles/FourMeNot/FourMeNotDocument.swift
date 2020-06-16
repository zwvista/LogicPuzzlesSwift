//
//  FourMeNotDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class FourMeNotDocument: GameDocument<FourMeNotGameMove> {
    static var sharedInstance = FourMeNotDocument()
    
    override func saveMove(_ move: FourMeNotGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> FourMeNotGameMove {
        FourMeNotGameMove(p: Position(rec.row, rec.col), obj: FourMeNotObject.fromString(str: rec.strValue1!))
    }
}
