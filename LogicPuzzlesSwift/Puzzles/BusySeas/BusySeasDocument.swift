//
//  BusySeasDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BusySeasDocument: GameDocument<BusySeasGameMove> {
    static var sharedInstance = BusySeasDocument()
    
    override func saveMove(_ move: BusySeasGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> BusySeasGameMove {
        BusySeasGameMove(p: Position(rec.row, rec.col), obj: BusySeasObject.fromString(str: rec.strValue1!))
    }
}
