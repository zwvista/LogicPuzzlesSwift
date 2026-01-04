//
//  CaffelatteDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CaffelatteDocument: GameDocument<CaffelatteGameMove> {
    static var sharedInstance = CaffelatteDocument()
    
    override func saveMove(_ move: CaffelatteGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> CaffelatteGameMove {
        CaffelatteGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
