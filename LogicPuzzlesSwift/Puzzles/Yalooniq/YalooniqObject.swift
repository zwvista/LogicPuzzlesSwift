//
//  YalooniqObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

typealias YalooniqObject = [Bool]

struct YalooniqHint {
    var num = 0
    var dir = 0
}

struct YalooniqGameMove {
    var p = Position()
    var dir = 0
}
