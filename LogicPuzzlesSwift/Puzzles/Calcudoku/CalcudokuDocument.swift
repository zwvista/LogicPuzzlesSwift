//
//  CalcudokuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CalcudokuDocument: GameDocument<CalcudokuGameMove> {
    static var sharedInstance = CalcudokuDocument()
    
    override func saveMove(_ move: CalcudokuGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> CalcudokuGameMove {
        CalcudokuGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
