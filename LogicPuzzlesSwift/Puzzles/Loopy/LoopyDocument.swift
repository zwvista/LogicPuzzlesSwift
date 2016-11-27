//
//  LoopyDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LoopyDocument: GameDocument<LoopyGame, LoopyGameMove> {
    static var sharedInstance = LoopyDocument()
    
    override func saveMove(_ move: LoopyGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.objOrientation.rawValue
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LoopyGameMove? {
        return LoopyGameMove(p: Position(rec.row, rec.col), objOrientation: LoopyObjectOrientation(rawValue: rec.intValue1)!, obj: LoopyObject(rawValue: rec.intValue2)!)
    }
}
