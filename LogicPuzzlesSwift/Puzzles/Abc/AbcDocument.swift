//
//  AbcDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class AbcDocument: GameDocument<AbcGame, AbcGameMove> {
    static var sharedInstance = AbcDocument()
    
    override func saveMove(_ move: AbcGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> AbcGameMove? {
        return AbcGameMove(p: Position(rec.row, rec.col), obj: rec.obj.characters.first!)
    }
}
