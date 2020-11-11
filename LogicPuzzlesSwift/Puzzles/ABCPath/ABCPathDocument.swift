//
//  ABCPathDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ABCPathDocument: GameDocument<ABCPathGameMove> {
    static var sharedInstance = ABCPathDocument()
    
    override func saveMove(_ move: ABCPathGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> ABCPathGameMove {
        ABCPathGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
