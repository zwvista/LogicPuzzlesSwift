//
//  NumberLinkDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class NumberLinkDocument: GameDocument<NumberLinkGameMove> {
    static var sharedInstance = NumberLinkDocument()
    
    override func saveMove(_ move: NumberLinkGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> NumberLinkGameMove {
        NumberLinkGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
