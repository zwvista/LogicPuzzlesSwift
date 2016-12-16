//
//  TentsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TentsDocument: GameDocument<TentsGame, TentsGameMove> {
    static var sharedInstance = TentsDocument()
    
    override func saveMove(_ move: TentsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> TentsGameMove? {
        return TentsGameMove(p: Position(rec.row, rec.col), obj: TentsObject(rawValue: rec.intValue1)!)
    }
}