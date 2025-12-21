//
//  RomeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RomeDocument: GameDocument<RomeGameMove> {
    static var sharedInstance = RomeDocument()
    
    override func saveMove(_ move: RomeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> RomeGameMove {
        RomeGameMove(p: Position(rec.row, rec.col), obj: RomeObject(rawValue: rec.intValue1)!)
    }
}
