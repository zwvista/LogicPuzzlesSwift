//
//  HeliumAndIronDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HeliumAndIronDocument: GameDocument<HeliumAndIronGameMove> {
    static var sharedInstance = HeliumAndIronDocument()
    
    override func saveMove(_ move: HeliumAndIronGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> HeliumAndIronGameMove {
        HeliumAndIronGameMove(p: Position(rec.row, rec.col), obj: HeliumAndIronObject(rawValue: rec.intValue1)!)
    }
}
