//
//  OnlyStraightsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OnlyStraightsDocument: GameDocument<OnlyStraightsGameMove> {
    static var sharedInstance = OnlyStraightsDocument()
    
    override func saveMove(_ move: OnlyStraightsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> OnlyStraightsGameMove {
        OnlyStraightsGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
