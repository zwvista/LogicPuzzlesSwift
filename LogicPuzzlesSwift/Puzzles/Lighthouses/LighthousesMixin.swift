//
//  LighthousesMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol LighthousesMixin: GameMixin {
}

extension LighthousesMixin {
    var gameDocumentBase: GameDocumentBase { return LighthousesDocument.sharedInstance }
    var gameDocument: LighthousesDocument { return LighthousesDocument.sharedInstance }
}
