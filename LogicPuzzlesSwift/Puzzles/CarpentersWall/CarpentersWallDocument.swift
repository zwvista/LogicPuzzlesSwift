//
//  CarpentersWallDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class CarpentersWallDocument: GameDocument<CarpentersWallGameMove> {
    static var sharedInstance = CarpentersWallDocument()
    
    override func saveMove(_ move: CarpentersWallGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> CarpentersWallGameMove? {
        return CarpentersWallGameMove(p: Position(rec.row, rec.col), obj: CarpentersWallObject.fromString(str: rec.strValue1!))
    }
}
