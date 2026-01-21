//
//  PleaseComeBackDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PleaseComeBackDocument: GameDocument<PleaseComeBackGameMove> {
    static var sharedInstance = PleaseComeBackDocument()
    
    override func saveMove(_ move: PleaseComeBackGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> PleaseComeBackGameMove {
        PleaseComeBackGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
