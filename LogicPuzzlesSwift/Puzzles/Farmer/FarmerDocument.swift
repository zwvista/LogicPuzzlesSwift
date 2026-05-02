//
//  FarmerDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FarmerDocument: GameDocument<FarmerGameMove> {
    static var sharedInstance = FarmerDocument()
    
    override func saveMove(_ move: FarmerGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> FarmerGameMove {
        FarmerGameMove(p: Position(rec.row, rec.col), obj: FarmerObject(rawValue: rec.intValue1)!)
    }
}
