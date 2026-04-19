//
//  TheGreyLabyrinthDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheGreyLabyrinthDocument: GameDocument<TheGreyLabyrinthGameMove> {
    static var sharedInstance = TheGreyLabyrinthDocument()
    
    override func saveMove(_ move: TheGreyLabyrinthGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> TheGreyLabyrinthGameMove {
        TheGreyLabyrinthGameMove(p: Position(rec.row, rec.col), obj: TheGreyLabyrinthObject(rawValue: rec.intValue1)!)
    }
}
