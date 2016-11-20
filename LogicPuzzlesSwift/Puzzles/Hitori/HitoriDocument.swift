//
//  HitoriDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class HitoriDocument: GameDocument<HitoriGame, HitoriGameMove> {
    static var sharedInstance = HitoriDocument()
    
    override func saveMove(_ move: HitoriGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.obj.rawValue.toString
    }
    
    override func loadMove(from rec: MoveProgress) -> HitoriGameMove? {
        return HitoriGameMove(p: Position(rec.row, rec.col), obj: HitoriObject(rawValue: rec.obj.toInt()!)!)
    }
}
