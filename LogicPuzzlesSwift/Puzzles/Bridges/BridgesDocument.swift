//
//  BridgesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BridgesDocument: GameDocument<BridgesGameMove> {
    static var sharedInstance = BridgesDocument()
    
    override func saveMove(_ move: BridgesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.pFrom.unapply()
        (rec.row2, rec.col2) = move.pTo.unapply()
    }
    
    override func loadMove(from rec: MoveProgress) -> BridgesGameMove? {
        BridgesGameMove(pFrom: Position(rec.row, rec.col), pTo: Position(rec.row2, rec.col2))
    }
}
