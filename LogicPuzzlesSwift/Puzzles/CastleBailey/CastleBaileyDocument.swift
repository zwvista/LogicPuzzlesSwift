//
//  CastleBaileyDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CastleBaileyDocument: GameDocument<CastleBaileyGameMove> {
    static var sharedInstance = CastleBaileyDocument()
    
    override func saveMove(_ move: CastleBaileyGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> CastleBaileyGameMove {
        CastleBaileyGameMove(p: Position(rec.row, rec.col), obj: CastleBaileyObject(rawValue: rec.intValue1)!)
    }
}
