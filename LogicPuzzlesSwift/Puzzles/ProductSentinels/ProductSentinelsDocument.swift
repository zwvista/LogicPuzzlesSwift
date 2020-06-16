//
//  ProductSentinelsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class ProductSentinelsDocument: GameDocument<ProductSentinelsGameMove> {
    static var sharedInstance = ProductSentinelsDocument()
    
    override func saveMove(_ move: ProductSentinelsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ProductSentinelsGameMove {
        ProductSentinelsGameMove(p: Position(rec.row, rec.col), obj: ProductSentinelsObject.fromString(str: rec.strValue1!))
    }
}
