//
//  FlowerOMinoObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum FlowerOMinoObject: Int {
    case empty, hedge, flower
}

struct FlowerOMinoRect {
    var area = [Position]()
    var rows = 0
    var cols = 0
}

struct FlowerOMinoGameMove {
    var p = Position()
    var dir = 0
    var obj = GridLineObject()
}
