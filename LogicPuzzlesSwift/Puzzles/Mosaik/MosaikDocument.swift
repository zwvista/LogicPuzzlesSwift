//
//  MosaikDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MosaikDocument: GameDocument<MosaikGameMove> {
    static var sharedInstance = MosaikDocument()
    
    override func saveMove(_ move: MosaikGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> MosaikGameMove? {
        MosaikGameMove(p: Position(rec.row, rec.col), obj: MosaikObject(rawValue: rec.intValue1)!)
    }
}
