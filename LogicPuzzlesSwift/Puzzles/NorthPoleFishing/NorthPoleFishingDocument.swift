//
//  NorthPoleFishingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class NorthPoleFishingDocument: GameDocument<NorthPoleFishingGameMove> {
    static var sharedInstance = NorthPoleFishingDocument()
    
    override func saveMove(_ move: NorthPoleFishingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> NorthPoleFishingGameMove {
        NorthPoleFishingGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1, obj: GridLineObject(rawValue: rec.intValue2)!)
    }
}
