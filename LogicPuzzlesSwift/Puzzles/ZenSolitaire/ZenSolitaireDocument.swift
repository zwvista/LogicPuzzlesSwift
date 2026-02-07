//
//  ZenSolitaireDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ZenSolitaireDocument: GameDocument<ZenSolitaireGameMove> {
    static var sharedInstance = ZenSolitaireDocument()
    
    override func saveMove(_ move: ZenSolitaireGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> ZenSolitaireGameMove {
        ZenSolitaireGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
