//
//  NooksDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NooksDocument: GameDocument<NooksGameMove> {
    static var sharedInstance = NooksDocument()
    
    override func saveMove(_ move: NooksGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> NooksGameMove {
        NooksGameMove(p: Position(rec.row, rec.col), obj: NooksObject.fromString(str: rec.strValue1!))
    }
}
