//
//  MirrorsExtendedDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MirrorsExtendedDocument: GameDocument<MirrorsExtendedGameMove> {
    static var sharedInstance = MirrorsExtendedDocument()
    
    override func saveMove(_ move: MirrorsExtendedGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> MirrorsExtendedGameMove {
        MirrorsExtendedGameMove(p: Position(rec.row, rec.col), obj: MirrorsExtendedObject(rawValue: rec.intValue1)!)
    }
}
