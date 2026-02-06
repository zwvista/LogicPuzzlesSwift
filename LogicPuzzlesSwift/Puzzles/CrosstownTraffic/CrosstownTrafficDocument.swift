//
//  CrosstownTrafficDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CrosstownTrafficDocument: GameDocument<CrosstownTrafficGameMove> {
    static var sharedInstance = CrosstownTrafficDocument()
    
    override func saveMove(_ move: CrosstownTrafficGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> CrosstownTrafficGameMove {
        CrosstownTrafficGameMove(p: Position(rec.row, rec.col), obj: CrosstownTrafficObject.fromString(str: rec.strValue1!))
    }
}
