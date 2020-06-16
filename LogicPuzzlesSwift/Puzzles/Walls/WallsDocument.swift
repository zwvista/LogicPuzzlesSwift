//
//  WallsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class WallsDocument: GameDocument<WallsGameMove> {
    static var sharedInstance = WallsDocument()
    
    override func saveMove(_ move: WallsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> WallsGameMove {
        WallsGameMove(p: Position(rec.row, rec.col), obj: WallsObject.fromString(str: rec.strValue1!))
    }
}
