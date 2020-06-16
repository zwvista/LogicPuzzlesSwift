//
//  BootyIslandDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class BootyIslandDocument: GameDocument<BootyIslandGameMove> {
    static var sharedInstance = BootyIslandDocument()
    
    override func saveMove(_ move: BootyIslandGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> BootyIslandGameMove {
        BootyIslandGameMove(p: Position(rec.row, rec.col), obj: BootyIslandObject.fromString(str: rec.strValue1!))
    }
}
