//
//  MasyuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MasyuDocument: GameDocument<MasyuGame, MasyuGameMove> {
    static var sharedInstance = MasyuDocument()
    
    override func saveMove(_ move: MasyuGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> MasyuGameMove? {
        return MasyuGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
