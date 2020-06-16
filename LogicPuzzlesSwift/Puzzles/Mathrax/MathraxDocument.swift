//
//  MathraxDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MathraxDocument: GameDocument<MathraxGameMove> {
    static var sharedInstance = MathraxDocument()
    
    override func saveMove(_ move: MathraxGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> MathraxGameMove {
        MathraxGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
