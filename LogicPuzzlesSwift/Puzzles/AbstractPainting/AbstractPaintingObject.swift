//
//  AbstractPaintingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum AbstractPaintingObject: Int {
    case empty, forbidden, marker
    case painting
    init() {
        self = .empty
    }
}

struct AbstractPaintingGameMove {
    var p = Position()
    var obj = AbstractPaintingObject()
}

