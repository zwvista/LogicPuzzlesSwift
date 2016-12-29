//
//  BoxItAroundObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BoxItAroundObject: Int {
    case empty
    case line
    case marker
    init() {
        self = .empty
    }
}

typealias BoxItAroundDotObject = [BoxItAroundObject]

struct BoxItAroundGameMove {
    var p = Position()
    var dir = 0
    var obj = BoxItAroundObject()
}
