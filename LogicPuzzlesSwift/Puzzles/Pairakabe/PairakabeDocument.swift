//
//  PairakabeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PairakabeDocument: GameDocument<PairakabeGameMove> {
    static var sharedInstance = PairakabeDocument()
    
    override func saveMove(_ move: PairakabeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> PairakabeGameMove {
        PairakabeGameMove(p: Position(rec.row, rec.col), obj: PairakabeObject.fromString(str: rec.strValue1!))
    }
}
