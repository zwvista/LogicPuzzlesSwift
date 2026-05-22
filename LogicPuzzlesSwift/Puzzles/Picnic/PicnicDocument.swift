//
//  PicnicDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PicnicDocument: GameDocument<PicnicGameMove> {
    static var sharedInstance = PicnicDocument()
    
    override func saveMove(_ move: PicnicGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> PicnicGameMove {
        PicnicGameMove(p: Position(rec.row, rec.col), obj: PicnicObject(rawValue: rec.intValue1)!)
    }
}
