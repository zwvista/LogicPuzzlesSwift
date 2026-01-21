//
//  SlitherCornerDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlitherCornerDocument: GameDocument<SlitherCornerGameMove> {
    static var sharedInstance = SlitherCornerDocument()
    
    override func saveMove(_ move: SlitherCornerGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> SlitherCornerGameMove {
        SlitherCornerGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1, obj: GridLineObject(rawValue: rec.intValue2)!)
    }
}
