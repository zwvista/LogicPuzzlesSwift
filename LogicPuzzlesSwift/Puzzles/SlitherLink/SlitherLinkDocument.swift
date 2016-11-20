//
//  SlitherLinkDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class SlitherLinkDocument: GameDocument<SlitherLinkGame, SlitherLinkGameMove> {
    static var sharedInstance = SlitherLinkDocument()
    
    override func saveMove(_ move: SlitherLinkGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.obj = move.objOrientation.rawValue.description
        rec.obj2 = move.obj.rawValue.description
    }
    
    override func loadMove(from rec: MoveProgress) -> SlitherLinkGameMove? {
        return SlitherLinkGameMove(p: Position(rec.row, rec.col), objOrientation: SlitherLinkObjectOrientation(rawValue: rec.obj.toInt()!)!, obj: SlitherLinkObject(rawValue: rec.obj2.toInt()!)!)
    }
}
