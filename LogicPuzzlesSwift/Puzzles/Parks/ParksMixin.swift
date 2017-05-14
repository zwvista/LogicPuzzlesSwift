//
//  ParksMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol ParksMixin: GameMixin {
}

extension ParksMixin {
    var gameDocumentBase: GameDocumentBase { return ParksDocument.sharedInstance }
    var gameDocument: ParksDocument { return ParksDocument.sharedInstance }
}
