//
//  HiddenPathDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HiddenPathDocument: GameDocument<HiddenPathGameMove> {
    static var sharedInstance = HiddenPathDocument()
    
    override func saveMove(_ move: HiddenPathGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
    }
    
    override func loadMove(from rec: MoveProgress) -> HiddenPathGameMove {
        HiddenPathGameMove(p: Position(rec.row, rec.col))
    }
}
