//
//  PowerGridDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class PowerGridDocument: GameDocument<PowerGridGameMove> {
    static var sharedInstance = PowerGridDocument()
    
    override func saveMove(_ move: PowerGridGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> PowerGridGameMove {
        PowerGridGameMove(p: Position(rec.row, rec.col), obj: PowerGridObject.fromString(str: rec.strValue1!))
    }
}
