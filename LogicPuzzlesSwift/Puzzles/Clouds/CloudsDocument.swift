//
//  CloudsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsDocument: GameDocument<CloudsGameMove> {
    static var sharedInstance = CloudsDocument()
    
    override func saveMove(_ move: CloudsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.intValue1 = move.obj.rawValue
    }
    
    override func loadMove(from rec: MoveProgress) -> CloudsGameMove {
        CloudsGameMove(p: Position(rec.row, rec.col), obj: CloudsObject(rawValue: rec.intValue1)!)
    }
}
