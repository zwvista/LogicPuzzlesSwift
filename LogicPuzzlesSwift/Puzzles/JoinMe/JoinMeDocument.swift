//
//  JoinMeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class JoinMeDocument: GameDocument<JoinMeGameMove> {
    static var sharedInstance = JoinMeDocument()
    
    override func saveMove(_ move: JoinMeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> JoinMeGameMove {
        JoinMeGameMove(p: Position(rec.row, rec.col), obj: JoinMeObject.fromString(str: rec.strValue1!))
    }
}
