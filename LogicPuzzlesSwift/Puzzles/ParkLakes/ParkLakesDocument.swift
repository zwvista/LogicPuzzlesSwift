//
//  ParkLakesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class ParkLakesDocument: GameDocument<ParkLakesGameMove> {
    static var sharedInstance = ParkLakesDocument()
    
    override func saveMove(_ move: ParkLakesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ParkLakesGameMove? {
        return ParkLakesGameMove(p: Position(rec.row, rec.col), obj: ParkLakesObject.fromString(str: rec.strValue1!))
    }
}
