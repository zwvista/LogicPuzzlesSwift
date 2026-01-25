//
//  FingerPointingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FingerPointingDocument: GameDocument<FingerPointingGameMove> {
    static var sharedInstance = FingerPointingDocument()
    
    override func saveMove(_ move: FingerPointingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> FingerPointingGameMove {
        FingerPointingGameMove(p: Position(rec.row, rec.col), obj: FingerPointingObject(rawValue: rec.intValue1)!)
    }
}
