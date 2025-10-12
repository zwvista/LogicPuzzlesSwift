//
//  KropkiDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KropkiDocument: GameDocument<KropkiGameMove> {
    static var sharedInstance = KropkiDocument()
    
    override func saveMove(_ move: KropkiGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> KropkiGameMove {
        KropkiGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
