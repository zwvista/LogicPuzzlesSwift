//
//  SnakeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeDocument: GameDocument<SnakeGameMove> {
    static var sharedInstance = SnakeDocument()
    
    override func saveMove(_ move: SnakeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> SnakeGameMove {
        SnakeGameMove(p: Position(rec.row, rec.col), obj: SnakeObject(rawValue: rec.intValue1)!)
    }
}
