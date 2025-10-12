//
//  TapARowDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TapARowDocument: GameDocument<TapARowGameMove> {
    static var sharedInstance = TapARowDocument()
    
    override func saveMove(_ move: TapARowGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TapARowGameMove {
        TapARowGameMove(p: Position(rec.row, rec.col), obj: TapARowObject.fromString(str: rec.strValue1!))
    }
}
