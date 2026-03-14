//
//  BalancedTapasDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BalancedTapasDocument: GameDocument<BalancedTapasGameMove> {
    static var sharedInstance = BalancedTapasDocument()
    
    override func saveMove(_ move: BalancedTapasGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> BalancedTapasGameMove {
        BalancedTapasGameMove(p: Position(rec.row, rec.col), obj: BalancedTapasObject(rawValue: rec.intValue1)!)
    }
}
