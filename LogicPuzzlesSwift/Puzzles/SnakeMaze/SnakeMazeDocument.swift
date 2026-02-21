//
//  SnakeMazeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeMazeDocument: GameDocument<SnakeMazeGameMove> {
    static var sharedInstance = SnakeMazeDocument()
    
    override func saveMove(_ move: SnakeMazeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> SnakeMazeGameMove {
        SnakeMazeGameMove(p: Position(rec.row, rec.col), obj: SnakeMazeObject(rawValue: rec.intValue1)!)
    }
}
