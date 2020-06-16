//
//  MagnetsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MagnetsAreaType: Int {
    case single, horizontal, vertical
}

struct MagnetsArea {
    var p = Position()
    var type: MagnetsAreaType = .single
}

enum MagnetsObject: Int {
    case empty, positive, negative, marker
    init() {
        self = .empty
    }
    func isEmpty() -> Bool { self == .empty || self == .marker }
    func isPole() -> Bool { self == .positive || self == .negative }
}

struct MagnetsGameMove {
    var p = Position()
    var obj = MagnetsObject()
}

