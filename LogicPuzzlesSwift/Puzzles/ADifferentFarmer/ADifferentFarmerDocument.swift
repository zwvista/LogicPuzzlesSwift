//
//  ADifferentFarmerDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ADifferentFarmerDocument: GameDocument<ADifferentFarmerGameMove> {
    static var sharedInstance = ADifferentFarmerDocument()
    
    override func saveMove(_ move: ADifferentFarmerGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> ADifferentFarmerGameMove {
        ADifferentFarmerGameMove(p: Position(rec.row, rec.col), obj: ADifferentFarmerObject(rawValue: rec.intValue1)!)
    }
}
