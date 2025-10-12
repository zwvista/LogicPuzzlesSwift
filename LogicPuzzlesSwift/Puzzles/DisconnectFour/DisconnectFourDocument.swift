//
//  DisconnectFourDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DisconnectFourDocument: GameDocument<DisconnectFourGameMove> {
    static var sharedInstance = DisconnectFourDocument()
    
    override func saveMove(_ move: DisconnectFourGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> DisconnectFourGameMove {
        DisconnectFourGameMove(p: Position(rec.row, rec.col), obj: DisconnectFourObject(rawValue: rec.intValue1)!)
    }
}
