//
//  ZenLandscaperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ZenLandscaperDocument: GameDocument<ZenLandscaperGameMove> {
    static var sharedInstance = ZenLandscaperDocument()
    
    override func saveMove(_ move: ZenLandscaperGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> ZenLandscaperGameMove {
        ZenLandscaperGameMove(p: Position(rec.row, rec.col), obj: ZenLandscaperObject.fromString(str: rec.strValue1!))
    }
}
