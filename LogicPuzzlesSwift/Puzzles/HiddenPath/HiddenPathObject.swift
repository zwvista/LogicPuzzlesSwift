//
//  HiddenPathObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct HiddenPathObject {
    var obj = 0
    var state: HintState = .normal
    var destructured: (Int, HintState) { (obj, state) }
}

struct HiddenPathGameMove {
    var p = Position()
}
