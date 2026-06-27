//
//  ProofOfQuiltDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ProofOfQuiltDocument: GameDocument<ProofOfQuiltGameMove> {
    static var sharedInstance = ProofOfQuiltDocument()
    
    override func saveMove(_ move: ProofOfQuiltGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.destructured
        rec.strValue1 = String(move.obj)
    }
    
    override func loadMove(from rec: MoveProgress) -> ProofOfQuiltGameMove {
        ProofOfQuiltGameMove(p: Position(rec.row, rec.col), obj: rec.strValue1![0])
    }
}
