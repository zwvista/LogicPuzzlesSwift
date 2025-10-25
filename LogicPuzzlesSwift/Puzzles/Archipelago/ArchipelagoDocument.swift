//
//  ArchipelagoDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ArchipelagoDocument: GameDocument<ArchipelagoGameMove> {
    static var sharedInstance = ArchipelagoDocument()
    
    override func saveMove(_ move: ArchipelagoGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ArchipelagoGameMove {
        ArchipelagoGameMove(p: Position(rec.row, rec.col), obj: ArchipelagoObject.fromString(str: rec.strValue1!))
    }
}
