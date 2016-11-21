//
//  LineSweeperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LineSweeperDocument: GameDocument<LineSweeperGame, LineSweeperGameMove> {
    static var sharedInstance = LineSweeperDocument()
    
    override func saveMove(_ move: LineSweeperGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.objOrientation.rawValue
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LineSweeperGameMove? {
        return LineSweeperGameMove(p: Position(rec.row, rec.col), objOrientation: LineSweeperObjectOrientation(rawValue: rec.intValue1)!, obj: LineSweeperObject(rawValue: rec.intValue2)!)
    }
}
