//
//  HitoriDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HitoriDocument: GameDocument<HitoriGameMove> {
    static var sharedInstance = HitoriDocument()
    
    override func saveMove(_ move: HitoriGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> HitoriGameMove {
        HitoriGameMove(p: Position(rec.row, rec.col), obj: HitoriObject(rawValue: rec.intValue1)!)
    }
}
