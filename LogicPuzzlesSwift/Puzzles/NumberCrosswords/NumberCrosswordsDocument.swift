//
//  NumberCrosswordsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberCrosswordsDocument: GameDocument<NumberCrosswordsGameMove> {
    static var sharedInstance = NumberCrosswordsDocument()
    
    override func saveMove(_ move: NumberCrosswordsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> NumberCrosswordsGameMove {
        NumberCrosswordsGameMove(p: Position(rec.row, rec.col), obj: NumberCrosswordsObject(rawValue: rec.intValue1)!)
    }
}
