//
//  RabbitsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RabbitsDocument: GameDocument<RabbitsGameMove> {
    static var sharedInstance = RabbitsDocument()
    
    override func saveMove(_ move: RabbitsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> RabbitsGameMove {
        RabbitsGameMove(p: Position(rec.row, rec.col), obj: RabbitsObject.fromString(str: rec.strValue1!))
    }
}
