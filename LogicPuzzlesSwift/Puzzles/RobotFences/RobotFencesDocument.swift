//
//  RobotFencesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class RobotFencesDocument: GameDocument<RobotFencesGame, RobotFencesGameMove> {
    static var sharedInstance = RobotFencesDocument()
    
    override func saveMove(_ move: RobotFencesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> RobotFencesGameMove? {
        return RobotFencesGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
