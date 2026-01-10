//
//  StepsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class StepsDocument: GameDocument<StepsGameMove> {
    static var sharedInstance = StepsDocument()
    
    override func saveMove(_ move: StepsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> StepsGameMove {
        StepsGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
