//
//  MineSlitherDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MineSlitherDocument: GameDocument<MineSlitherGameMove> {
    static var sharedInstance = MineSlitherDocument()
    
    override func saveMove(_ move: MineSlitherGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> MineSlitherGameMove {
        MineSlitherGameMove(p: Position(rec.row, rec.col), obj: MineSlitherObject(rawValue: rec.intValue1)!)
    }
}
