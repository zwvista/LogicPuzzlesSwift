//
//  MagnetsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MagnetsDocument: GameDocument<MagnetsGameMove> {
    static var sharedInstance = MagnetsDocument()
    
    override func saveMove(_ move: MagnetsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> MagnetsGameMove {
        MagnetsGameMove(p: Position(rec.row, rec.col), obj: MagnetsObject(rawValue: rec.intValue1)!)
    }
}
