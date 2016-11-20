//
//  SkyscrapersDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SkyscrapersDocument: GameDocument<SkyscrapersGame, SkyscrapersGameMove> {
    static var sharedInstance = SkyscrapersDocument()
    
    override func saveMove(_ move: SkyscrapersGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.obj.description
    }
    
    override func loadMove(from rec: MoveProgress) -> SkyscrapersGameMove? {
        return SkyscrapersGameMove(p: Position(rec.row, rec.col), obj: rec.obj.toInt()!)
    }
}
