//
//  HidokuObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct HidokuObject {
    var obj = 0
    var state: HintState = .normal
    var destructured: (Int, HintState) { (obj, state) }
}

struct HidokuGameMove {
    var p = Position()
    var obj = 0
}
