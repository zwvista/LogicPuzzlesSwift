//
//  SlitherLinkDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlitherLinkDocument: GameDocument<SlitherLinkGameMove> {
    static var sharedInstance = SlitherLinkDocument()
    
    override func saveMove(_ move: SlitherLinkGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.intValue1 = move.dir
        rec.intValue2 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> SlitherLinkGameMove {
        SlitherLinkGameMove(p: Position(rec.row, rec.col), dir: rec.intValue1, obj: GridLineObject(rawValue: rec.intValue2)!)
    }
}
