//
//  MiniLitsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MiniLitsDocument: GameDocument<MiniLitsGameMove> {
    static var sharedInstance = MiniLitsDocument()
    
    override func saveMove(_ move: MiniLitsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> MiniLitsGameMove {
        MiniLitsGameMove(p: Position(rec.row, rec.col), obj: MiniLitsObject(rawValue: rec.intValue1)!)
    }
}
