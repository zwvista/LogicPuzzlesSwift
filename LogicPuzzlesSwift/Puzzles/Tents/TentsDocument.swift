//
//  TentsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TentsDocument: GameDocument<TentsGameMove> {
    static var sharedInstance = TentsDocument()
    
    override func saveMove(_ move: TentsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TentsGameMove? {
        TentsGameMove(p: Position(rec.row, rec.col), obj: TentsObject.fromString(str: rec.strValue1!))
    }
}
