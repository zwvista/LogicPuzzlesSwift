//
//  ChocolateDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ChocolateDocument: GameDocument<ChocolateGameMove> {
    static var sharedInstance = ChocolateDocument()
    
    override func saveMove(_ move: ChocolateGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> ChocolateGameMove {
        ChocolateGameMove(p: Position(rec.row, rec.col), obj: ChocolateObject(rawValue: rec.intValue1)!)
    }
}
