//
//  BranchesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BranchesDocument: GameDocument<BranchesGameMove> {
    static var sharedInstance = BranchesDocument()
    
    override func saveMove(_ move: BranchesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> BranchesGameMove {
        BranchesGameMove(p: Position(rec.row, rec.col), obj: BranchesObject.fromString(str: rec.strValue1!))
    }
}
