//
//  FillominoDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FillominoDocument: GameDocument<FillominoGameMove> {
    static var sharedInstance = FillominoDocument()
    
    override func saveMove(_ move: FillominoGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> FillominoGameMove {
        FillominoGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
