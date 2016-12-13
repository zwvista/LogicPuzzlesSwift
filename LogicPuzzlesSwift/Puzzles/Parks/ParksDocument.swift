//
//  ParksDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class ParksDocument: GameDocument<ParksGame, ParksGameMove> {
    static var sharedInstance = ParksDocument()
    
    override func saveMove(_ move: ParksGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> ParksGameMove? {
        return ParksGameMove(p: Position(rec.row, rec.col), obj: ParksObject(rawValue: rec.intValue1)!)
    }
}
