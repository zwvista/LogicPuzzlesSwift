//
//  HiddenStarsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HiddenStarsDocument: GameDocument<HiddenStarsGameMove> {
    static var sharedInstance = HiddenStarsDocument()
    
    override func saveMove(_ move: HiddenStarsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> HiddenStarsGameMove {
        HiddenStarsGameMove(p: Position(rec.row, rec.col), obj: HiddenStarsObject.fromString(str: rec.strValue1!))
    }
}
