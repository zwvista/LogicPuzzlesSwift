//
//  SkyscrapersDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SkyscrapersDocument: GameDocument<SkyscrapersGameMove> {
    static var sharedInstance = SkyscrapersDocument()
    
    override func saveMove(_ move: SkyscrapersGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> SkyscrapersGameMove {
        SkyscrapersGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
