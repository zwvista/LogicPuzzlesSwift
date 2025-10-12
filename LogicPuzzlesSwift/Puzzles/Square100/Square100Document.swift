//
//  Square100Document.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class Square100Document: GameDocument<Square100GameMove> {
    static var sharedInstance = Square100Document()
    
    override func saveMove(_ move: Square100GameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> Square100GameMove {
        Square100GameMove(p: Position(rec.row, rec.col), isRightPart: false, obj: rec.strValue1!)
    }
}
