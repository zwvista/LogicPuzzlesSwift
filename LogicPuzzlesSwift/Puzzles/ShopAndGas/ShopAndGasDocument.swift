//
//  ShopAndGasDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ShopAndGasDocument: GameDocument<ShopAndGasGameMove> {
    static var sharedInstance = ShopAndGasDocument()
    
    override func saveMove(_ move: ShopAndGasGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.dir
    }
    
    override func loadMove(from rec: MoveProgress) -> ShopAndGasGameMove {
        ShopAndGasGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1)
    }
}
