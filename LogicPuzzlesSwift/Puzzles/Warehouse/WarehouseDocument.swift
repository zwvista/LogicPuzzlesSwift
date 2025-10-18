//
//  WarehouseDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WarehouseDocument: GameDocument<WarehouseGameMove> {
    static var sharedInstance = WarehouseDocument()
    
    override func saveMove(_ move: WarehouseGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> WarehouseGameMove {
        WarehouseGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1, obj: GridLineObject(rawValue: rec.intValue2)!)
    }
}
