//
//  BalancedTapasDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BalancedTapasDocument: GameDocument<BalancedTapasGameMove> {
    static var sharedInstance = BalancedTapasDocument()
    
    override func saveMove(_ move: BalancedTapasGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> BalancedTapasGameMove {
        BalancedTapasGameMove(p: Position(rec.row, rec.col), obj: BalancedTapasObject.fromString(str: rec.strValue1!))
    }
}
