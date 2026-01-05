//
//  InbetweenSumscrapersDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class InbetweenSumscrapersDocument: GameDocument<InbetweenSumscrapersGameMove> {
    static var sharedInstance = InbetweenSumscrapersDocument()
    
    override func saveMove(_ move: InbetweenSumscrapersGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> InbetweenSumscrapersGameMove {
        InbetweenSumscrapersGameMove(p: Position(rec.row, rec.col), obj: InbetweenSumscrapersObject.fromString(str: rec.strValue1!))
    }
}
