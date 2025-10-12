//
//  HidokuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HidokuDocument: GameDocument<HidokuGameMove> {
    static var sharedInstance = HidokuDocument()
    
    override func saveMove(_ move: HidokuGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
    }
    
    override func loadMove(from rec: MoveProgress) -> HidokuGameMove {
        HidokuGameMove(p: Position(rec.row, rec.col))
    }
}
