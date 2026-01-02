//
//  PouringWaterDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PouringWaterDocument: GameDocument<PouringWaterGameMove> {
    static var sharedInstance = PouringWaterDocument()
    
    override func saveMove(_ move: PouringWaterGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> PouringWaterGameMove {
        PouringWaterGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
