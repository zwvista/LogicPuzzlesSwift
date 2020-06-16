//
//  TapaIslandsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class TapaIslandsDocument: GameDocument<TapaIslandsGameMove> {
    static var sharedInstance = TapaIslandsDocument()
    
    override func saveMove(_ move: TapaIslandsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TapaIslandsGameMove? {
        TapaIslandsGameMove(p: Position(rec.row, rec.col), obj: TapaIslandsObject.fromString(str: rec.strValue1!))
    }
}
