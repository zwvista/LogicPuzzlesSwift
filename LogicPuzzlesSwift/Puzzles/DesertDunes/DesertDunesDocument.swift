//
//  DesertDunesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DesertDunesDocument: GameDocument<DesertDunesGameMove> {
    static var sharedInstance = DesertDunesDocument()
    
    override func saveMove(_ move: DesertDunesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> DesertDunesGameMove {
        DesertDunesGameMove(p: Position(rec.row, rec.col), obj: DesertDunesObject.fromString(str: rec.strValue1!))
    }
}
