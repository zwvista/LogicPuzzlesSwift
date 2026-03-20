//
//  PataDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PataDocument: GameDocument<PataGameMove> {
    static var sharedInstance = PataDocument()
    
    override func saveMove(_ move: PataGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> PataGameMove {
        PataGameMove(p: Position(rec.row, rec.col), obj: PataObject(rawValue: rec.intValue1)!)
    }
}
