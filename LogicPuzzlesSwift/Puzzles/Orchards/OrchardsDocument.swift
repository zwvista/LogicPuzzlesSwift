//
//  OrchardsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OrchardsDocument: GameDocument<OrchardsGameMove> {
    static var sharedInstance = OrchardsDocument()
    
    override func saveMove(_ move: OrchardsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> OrchardsGameMove {
        OrchardsGameMove(p: Position(rec.row, rec.col), obj: OrchardsObject.fromString(str: rec.strValue1!))
    }
}
