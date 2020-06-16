//
//  AbstractPaintingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class AbstractPaintingDocument: GameDocument<AbstractPaintingGameMove> {
    static var sharedInstance = AbstractPaintingDocument()
    
    override func saveMove(_ move: AbstractPaintingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> AbstractPaintingGameMove {
        AbstractPaintingGameMove(p: Position(rec.row, rec.col), obj: AbstractPaintingObject(rawValue: rec.intValue1)!)
    }
}
