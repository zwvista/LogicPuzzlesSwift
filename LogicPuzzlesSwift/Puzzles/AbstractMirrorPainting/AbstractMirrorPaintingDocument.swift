//
//  AbstractMirrorPaintingDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class AbstractMirrorPaintingDocument: GameDocument<AbstractMirrorPaintingGameMove> {
    static var sharedInstance = AbstractMirrorPaintingDocument()
    
    override func saveMove(_ move: AbstractMirrorPaintingGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> AbstractMirrorPaintingGameMove {
        AbstractMirrorPaintingGameMove(p: Position(rec.row, rec.col), obj: AbstractMirrorPaintingObject(rawValue: rec.intValue1)!)
    }
}
