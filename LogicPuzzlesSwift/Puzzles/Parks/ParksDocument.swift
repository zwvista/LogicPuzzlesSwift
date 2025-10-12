//
//  ParksDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ParksDocument: GameDocument<ParksGameMove> {
    static var sharedInstance = ParksDocument()
    
    override func saveMove(_ move: ParksGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ParksGameMove {
        ParksGameMove(p: Position(rec.row, rec.col), obj: ParksObject.fromString(str: rec.strValue1!))
    }
}
