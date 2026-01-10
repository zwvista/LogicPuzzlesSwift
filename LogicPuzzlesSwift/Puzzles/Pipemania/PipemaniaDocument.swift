//
//  PipemaniaDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PipemaniaDocument: GameDocument<PipemaniaGameMove> {
    static var sharedInstance = PipemaniaDocument()
    
    override func saveMove(_ move: PipemaniaGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> PipemaniaGameMove {
        PipemaniaGameMove(p: Position(rec.row, rec.col), obj: PipemaniaObject.fromString(str: rec.strValue1!))
    }
}
