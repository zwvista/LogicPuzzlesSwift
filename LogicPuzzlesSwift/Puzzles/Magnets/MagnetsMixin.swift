//
//  MagnetsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol MagnetsMixin: GameMixin {
}

extension MagnetsMixin {
    var gameDocumentBase: GameDocumentBase { return MagnetsDocument.sharedInstance }
    var gameDocument: MagnetsDocument { return MagnetsDocument.sharedInstance }
}
