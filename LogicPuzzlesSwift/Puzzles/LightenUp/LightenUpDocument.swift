//
//  LightenUpDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightenUpDocument: GameDocument<LightenUpGameMove> {
    static var sharedInstance = LightenUpDocument()
    
    override func saveMove(_ move: LightenUpGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.objType.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LightenUpGameMove {
        LightenUpGameMove(p: Position(rec.row, rec.col), objType: LightenUpObjectType(rawValue: rec.intValue1)!)
    }
}
