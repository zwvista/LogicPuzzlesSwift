//
//  NoughtsAndCrossesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class NoughtsAndCrossesDocument: GameDocument<NoughtsAndCrossesGame, NoughtsAndCrossesGameMove> {
    static var sharedInstance = NoughtsAndCrossesDocument()
    
    override func saveMove(_ move: NoughtsAndCrossesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.description
    }
    
    override func loadMove(from rec: MoveProgress) -> NoughtsAndCrossesGameMove? {
        return NoughtsAndCrossesGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
