//
//  KakurasuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class KakurasuDocument: GameDocument<KakurasuGame, KakurasuGameMove> {
    static var sharedInstance = KakurasuDocument()
    
    override func saveMove(_ move: KakurasuGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj
    }
    
    override func loadMove(from rec: MoveProgress) -> KakurasuGameMove? {
        return KakurasuGameMove(p: Position(rec.row, rec.col), obj: rec.intValue1)
    }
}
