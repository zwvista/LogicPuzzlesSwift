//
//  WallSentinelsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WallSentinelsDocument: GameDocument<WallSentinelsGameMove> {
    static var sharedInstance = WallSentinelsDocument()
    
    override func saveMove(_ move: WallSentinelsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> WallSentinelsGameMove {
        WallSentinelsGameMove(p: Position(rec.row, rec.col), obj: WallSentinelsObject.fromString(str: rec.strValue1!))
    }
}
