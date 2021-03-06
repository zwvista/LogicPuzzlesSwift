//
//  MathraxObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct MathraxHint {
    var op: Character = " "
    var result = 0
    func description() -> String {
        (result == 0 ? "" : String(result)) + String(op)
    }
}

struct MathraxGameMove {
    var p = Position()
    var obj = 0
}

