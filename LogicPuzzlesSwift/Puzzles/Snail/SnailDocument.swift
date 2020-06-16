//
//  SnailDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SnailDocument: GameDocument<SnailGameMove> {
    static var sharedInstance = SnailDocument()
    
    override func saveMove(_ move: SnailGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> SnailGameMove {
        SnailGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
