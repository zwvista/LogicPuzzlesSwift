//
//  TheOddBrickDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TheOddBrickDocument: GameDocument<TheOddBrickGame, TheOddBrickGameMove> {
    static var sharedInstance = TheOddBrickDocument()
    
    override func saveMove(_ move: TheOddBrickGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> TheOddBrickGameMove? {
        return TheOddBrickGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}