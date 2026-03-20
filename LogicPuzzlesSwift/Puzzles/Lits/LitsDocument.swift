//
//  LitsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LitsDocument: GameDocument<LitsGameMove> {
    static var sharedInstance = LitsDocument()
    
    override func saveMove(_ move: LitsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LitsGameMove {
        LitsGameMove(p: Position(rec.row, rec.col), obj: LitsObject(rawValue: rec.intValue1)!)
    }
}
