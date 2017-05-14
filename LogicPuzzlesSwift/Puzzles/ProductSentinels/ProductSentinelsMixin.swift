//
//  ProductSentinelsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol ProductSentinelsMixin: GameMixin {
}

extension ProductSentinelsMixin {
    var gameDocumentBase: GameDocumentBase { return ProductSentinelsDocument.sharedInstance }
    var gameDocument: ProductSentinelsDocument { return ProductSentinelsDocument.sharedInstance }
}
