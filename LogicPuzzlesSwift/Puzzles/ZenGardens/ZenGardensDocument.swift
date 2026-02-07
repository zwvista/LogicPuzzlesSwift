//
//  ZenGardensDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ZenGardensDocument: GameDocument<ZenGardensGameMove> {
    static var sharedInstance = ZenGardensDocument()
    
    override func saveMove(_ move: ZenGardensGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> ZenGardensGameMove {
        ZenGardensGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
