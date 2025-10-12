//
//  TataminoDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TataminoDocument: GameDocument<TataminoGameMove> {
    static var sharedInstance = TataminoDocument()
    
    override func saveMove(_ move: TataminoGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> TataminoGameMove {
        TataminoGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
