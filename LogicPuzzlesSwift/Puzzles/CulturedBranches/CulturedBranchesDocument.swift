//
//  CulturedBranchesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CulturedBranchesDocument: GameDocument<CulturedBranchesGameMove> {
    static var sharedInstance = CulturedBranchesDocument()
    
    override func saveMove(_ move: CulturedBranchesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> CulturedBranchesGameMove {
        CulturedBranchesGameMove(p: Position(rec.row, rec.col), obj: CulturedBranchesObject(rawValue: rec.intValue1)!)
    }
}
