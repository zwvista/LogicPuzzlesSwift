//
//  AbstractMirrorPaintingObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum AbstractMirrorPaintingObject: Int {
    case empty, painted, forbidden, marker
    init() {
        self = .empty
    }
}

struct AbstractMirrorPaintingMirror {
    let p1, p2: Position
    let areaId1, areaId2: Int
}

struct AbstractMirrorPaintingGameMove {
    var p = Position()
    var obj = AbstractMirrorPaintingObject()
}
