//
//  LandscaperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LandscaperDocument: GameDocument<LandscaperGameMove> {
    static var sharedInstance = LandscaperDocument()
    
    override func saveMove(_ move: LandscaperGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> LandscaperGameMove {
        LandscaperGameMove(p: Position(rec.row, rec.col), obj: LandscaperObject(rawValue: rec.intValue1)!)
    }
}
