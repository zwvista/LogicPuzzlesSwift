//
//  TheCityRisesDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheCityRisesDocument: GameDocument<TheCityRisesGameMove> {
    static var sharedInstance = TheCityRisesDocument()
    
    override func saveMove(_ move: TheCityRisesGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> TheCityRisesGameMove {
        TheCityRisesGameMove(p: Position(rec.row, rec.col), obj: TheCityRisesObject.fromString(str: rec.strValue1!))
    }
}
