//
//  BusySeasMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol BusySeasMixin: GameMixin {
}

extension BusySeasMixin {
    var gameDocumentBase: GameDocumentBase { return BusySeasDocument.sharedInstance }
    var gameDocument: BusySeasDocument { return BusySeasDocument.sharedInstance }
}
