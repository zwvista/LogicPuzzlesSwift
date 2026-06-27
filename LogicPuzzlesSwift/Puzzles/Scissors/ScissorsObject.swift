//
//  ScissorsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct ScissorsPosition: Hashable {
    let p: Position
    let n: Int
    
    var description: String {
        "(\(p.row),\(p.col),\(n))"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(p)
        hasher.combine(n)
    }
}

struct ScissorsGameMove {
    var p = Position()
    var obj: Character = " "
}
