//
//  SentinelsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SentinelsDocument: GameDocument<SentinelsGameMove> {
    static var sharedInstance = SentinelsDocument()
    
    override func saveMove(_ move: SentinelsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> SentinelsGameMove {
        SentinelsGameMove(p: Position(rec.row, rec.col), obj: SentinelsObject.fromString(str: rec.strValue1!))
    }
}
