//
//  BotanicalParkDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BotanicalParkDocument: GameDocument<BotanicalParkGameMove> {
    static var sharedInstance = BotanicalParkDocument()
    
    override func saveMove(_ move: BotanicalParkGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> BotanicalParkGameMove {
        BotanicalParkGameMove(p: Position(rec.row, rec.col), obj: BotanicalParkObject(rawValue: rec.intValue1)!)
    }
}
