//
//  HolidayIslandDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HolidayIslandDocument: GameDocument<HolidayIslandGameMove> {
    static var sharedInstance = HolidayIslandDocument()
    
    override func saveMove(_ move: HolidayIslandGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> HolidayIslandGameMove {
        HolidayIslandGameMove(p: Position(rec.row, rec.col), obj: HolidayIslandObject.fromString(str: rec.strValue1!))
    }
}
