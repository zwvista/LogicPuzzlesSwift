//
//  TheGreyLabyrinthObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum TheGreyLabyrinthObject: Int {
    case empty, treasure, up, right, down, left
    case forbidden, marker, wall
    init() {
        self = .empty
    }
}

struct TheGreyLabyrinthGameMove {
    var p = Position()
    var obj = TheGreyLabyrinthObject()
}
