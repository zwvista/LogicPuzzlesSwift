//
//  SlantedMazeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlantedMazeDocument: GameDocument<SlantedMazeGameMove> {
    static var sharedInstance = SlantedMazeDocument()
    
    override func saveMove(_ move: SlantedMazeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> SlantedMazeGameMove {
        SlantedMazeGameMove(p: Position(rec.row, rec.col), obj: SlantedMazeObject(rawValue: rec.intValue1)!)
    }
}
