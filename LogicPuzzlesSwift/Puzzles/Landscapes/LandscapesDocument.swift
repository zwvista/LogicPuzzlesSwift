//
//  LandscapesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LandscapesDocument: GameDocument<LandscapesGameMove> {
    static var sharedInstance = LandscapesDocument()
    
    override func saveMove(_ move: LandscapesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> LandscapesGameMove {
        LandscapesGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
