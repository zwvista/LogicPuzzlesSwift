//
//  ParkLakesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ParkLakesDocument: GameDocument<ParkLakesGameMove> {
    static var sharedInstance = ParkLakesDocument()
    
    override func saveMove(_ move: ParkLakesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> ParkLakesGameMove {
        ParkLakesGameMove(p: Position(rec.row, rec.col), obj: ParkLakesObject(rawValue: rec.intValue1)!)
    }
}
