//
//  VeniceDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class VeniceDocument: GameDocument<VeniceGameMove> {
    static var sharedInstance = VeniceDocument()
    
    override func saveMove(_ move: VeniceGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> VeniceGameMove {
        VeniceGameMove(p: Position(rec.row, rec.col), obj: VeniceObject(rawValue: rec.intValue1)!)
    }
}
