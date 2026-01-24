//
//  StraightAndBendLandsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class StraightAndBendLandsDocument: GameDocument<StraightAndBendLandsGameMove> {
    static var sharedInstance = StraightAndBendLandsDocument()
    
    override func saveMove(_ move: StraightAndBendLandsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> StraightAndBendLandsGameMove {
        StraightAndBendLandsGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
