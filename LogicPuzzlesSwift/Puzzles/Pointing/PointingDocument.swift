//
//  PointingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PointingDocument: GameDocument<PointingGameMove> {
    static var sharedInstance = PointingDocument()
    
    override func saveMove(_ move: PointingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
    }
    
    override func loadMove(from rec: MoveProgress) -> PointingGameMove {
        PointingGameMove(p: Position(rec.row, rec.col))
    }
}
