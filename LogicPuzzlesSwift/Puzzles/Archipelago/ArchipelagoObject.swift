//
//  ArchipelagoObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ArchipelagoObject: Int {
    case empty, hint, marker, water
    init() {
        self = .empty
    }
}

struct ArchipelagoGameMove {
    var p = Position()
    var obj = ArchipelagoObject()
}
