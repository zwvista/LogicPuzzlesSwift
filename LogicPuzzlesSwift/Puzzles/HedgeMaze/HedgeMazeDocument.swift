//
//  HedgeMazeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HedgeMazeDocument: GameDocument<HedgeMazeGameMove> {
    static var sharedInstance = HedgeMazeDocument()
    
    override func saveMove(_ move: HedgeMazeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> HedgeMazeGameMove {
        HedgeMazeGameMove(p: Position(rec.row, rec.col), obj: HedgeMazeObject(rawValue: rec.intValue1)!)
    }
}
