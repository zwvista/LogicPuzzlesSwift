//
//  WishSandwichDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WishSandwichDocument: GameDocument<WishSandwichGameMove> {
    static var sharedInstance = WishSandwichDocument()
    
    override func saveMove(_ move: WishSandwichGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> WishSandwichGameMove {
        WishSandwichGameMove(p: Position(rec.row, rec.col), obj: WishSandwichObject.fromString(str: rec.strValue1!))
    }
}
