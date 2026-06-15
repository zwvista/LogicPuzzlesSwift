//
//  ScissorsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ScissorsDocument: GameDocument<ScissorsGameMove> {
    static var sharedInstance = ScissorsDocument()
    
    override func saveMove(_ move: ScissorsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> ScissorsGameMove {
        ScissorsGameMove(p: Position(rec.row, rec.col), obj: ScissorsObject(rawValue: rec.intValue1)!)
    }
}
