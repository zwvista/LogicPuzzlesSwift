//
//  CloudsAndClearsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsAndClearsDocument: GameDocument<CloudsAndClearsGameMove> {
    static var sharedInstance = CloudsAndClearsDocument()
    
    override func saveMove(_ move: CloudsAndClearsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> CloudsAndClearsGameMove {
        CloudsAndClearsGameMove(p: Position(rec.row, rec.col), obj: CloudsAndClearsObject(rawValue: rec.intValue1)!)
    }
}
