//
//  ThermometersDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ThermometersDocument: GameDocument<ThermometersGameMove> {
    static var sharedInstance = ThermometersDocument()
    
    override func saveMove(_ move: ThermometersGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ThermometersGameMove {
        ThermometersGameMove(p: Position(rec.row, rec.col), obj: ThermometersObject.fromString(str: rec.strValue1!))
    }
}
