//
//  UnreliableHintsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class UnreliableHintsDocument: GameDocument<UnreliableHintsGameMove> {
    static var sharedInstance = UnreliableHintsDocument()
    
    override func saveMove(_ move: UnreliableHintsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> UnreliableHintsGameMove {
        UnreliableHintsGameMove(p: Position(rec.row, rec.col), obj: UnreliableHintsObject(rawValue: rec.intValue1)!)
    }
}
