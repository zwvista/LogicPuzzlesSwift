//
//  NumberCrossingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberCrossingDocument: GameDocument<NumberCrossingGameMove> {
    static var sharedInstance = NumberCrossingDocument()
    
    override func saveMove(_ move: NumberCrossingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> NumberCrossingGameMove {
        NumberCrossingGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
