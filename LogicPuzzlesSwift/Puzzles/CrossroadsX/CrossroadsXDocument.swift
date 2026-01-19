//
//  CrossroadsXDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CrossroadsXDocument: GameDocument<CrossroadsXGameMove> {
    static var sharedInstance = CrossroadsXDocument()
    
    override func saveMove(_ move: CrossroadsXGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> CrossroadsXGameMove {
        CrossroadsXGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
