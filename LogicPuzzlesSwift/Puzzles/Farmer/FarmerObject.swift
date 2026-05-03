//
//  FarmerObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FarmerObject: Int {
    case empty, fv1, fv2, fv3
    init() {
        self = .empty
    }
}

struct FarmerGameMove {
    var p = Position()
    var obj = FarmerObject()
}
