//
//  PlanetsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PlanetsDocument: GameDocument<PlanetsGameMove> {
    static var sharedInstance = PlanetsDocument()
    
    override func saveMove(_ move: PlanetsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> PlanetsGameMove {
        PlanetsGameMove(p: Position(rec.row, rec.col), obj: PlanetsObject(rawValue: rec.intValue1)!)
    }
}
