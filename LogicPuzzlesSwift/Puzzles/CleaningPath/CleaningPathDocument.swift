//
//  CleaningPathDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CleaningPathDocument: GameDocument<CleaningPathGameMove> {
    static var sharedInstance = CleaningPathDocument()
    
    override func saveMove(_ move: CleaningPathGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> CleaningPathGameMove {
        CleaningPathGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
