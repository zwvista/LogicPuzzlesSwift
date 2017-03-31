//
//  LighthousesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class LighthousesDocument: GameDocument<LighthousesGame, LighthousesGameMove> {
    static var sharedInstance = LighthousesDocument()
    
    override func saveMove(_ move: LighthousesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> LighthousesGameMove? {
        return LighthousesGameMove(p: Position(rec.row, rec.col), obj: LighthousesObject.fromString(str: rec.strValue1!))
    }
}
