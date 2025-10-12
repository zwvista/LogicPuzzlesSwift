//
//  KakurasuDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KakurasuDocument: GameDocument<KakurasuGameMove> {
    static var sharedInstance = KakurasuDocument()
    
    override func saveMove(_ move: KakurasuGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> KakurasuGameMove {
        KakurasuGameMove(p: Position(rec.row, rec.col), obj: KakurasuObject(rawValue: rec.intValue1)!)
    }
}
