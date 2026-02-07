//
//  CastlePatrolDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CastlePatrolDocument: GameDocument<CastlePatrolGameMove> {
    static var sharedInstance = CastlePatrolDocument()
    
    override func saveMove(_ move: CastlePatrolGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.objType.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> CastlePatrolGameMove {
        CastlePatrolGameMove(p: Position(rec.row, rec.col), objType: CastlePatrolObjectType.fromString(str: rec.strValue1!))
    }
}
