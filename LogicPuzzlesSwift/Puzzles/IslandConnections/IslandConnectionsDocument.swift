//
//  IslandConnectionsDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class IslandConnectionsDocument: GameDocument<IslandConnectionsGameMove> {
    static var sharedInstance = IslandConnectionsDocument()
    
    override func saveMove(_ move: IslandConnectionsGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.pFrom.destructured
        (rec.row2, rec.col2) = move.pTo.destructured
    }
    
    override func loadMove(from rec: MoveProgress) -> IslandConnectionsGameMove {
        IslandConnectionsGameMove(pFrom: Position(rec.row, rec.col), pTo: Position(rec.row2, rec.col2))
    }
}
