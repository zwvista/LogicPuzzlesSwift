//
//  PaintTheNurikabeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class PaintTheNurikabeDocument: GameDocument<PaintTheNurikabeGame, PaintTheNurikabeGameMove> {
    static var sharedInstance = PaintTheNurikabeDocument()
    
    override func saveMove(_ move: PaintTheNurikabeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> PaintTheNurikabeGameMove? {
        return PaintTheNurikabeGameMove(p: Position(rec.row, rec.col), obj: PaintTheNurikabeObject(rawValue: rec.intValue1)!)
    }
}
