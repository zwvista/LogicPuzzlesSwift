//
//  LineSweeperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LineSweeperDocument: GameDocument<LineSweeperGameMove> {
    static var sharedInstance = LineSweeperDocument()
    
    override func saveMove(_ move: LineSweeperGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> LineSweeperGameMove {
        LineSweeperGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
