//
//  TapaDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TapaDocument: GameDocument<TapaGameMove> {
    static var sharedInstance = TapaDocument()
    
    override func saveMove(_ move: TapaGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TapaGameMove {
        TapaGameMove(p: Position(rec.row, rec.col), obj: TapaObject.fromString(str: rec.strValue1!))
    }
}
