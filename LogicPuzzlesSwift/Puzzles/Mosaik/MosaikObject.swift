//
//  MosaikObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum MosaikObject: Int {
    case empty, filled, marker
    init() {
        self = .empty
    }
}

struct MosaikGameMove {
    var p = Position()
    var obj = MosaikObject()
}
