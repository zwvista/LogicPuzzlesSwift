//
//  ProductSentinelsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum ProductSentinelsObject: Int {
    case empty, forbidden, hint, marker
    case tower
    init() {
        self = .empty
    }
}

struct ProductSentinelsGameMove {
    var p = Position()
    var obj = ProductSentinelsObject()
}
