//
//  GemsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GemsDocument: GameDocument<GemsGameMove> {
    static var sharedInstance = GemsDocument()
    
    override func saveMove(_ move: GemsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> GemsGameMove {
        GemsGameMove(p: Position(rec.row, rec.col), obj: GemsObject.fromString(str: rec.strValue1!))
    }
}
