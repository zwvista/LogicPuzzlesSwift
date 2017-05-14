//
//  CloudsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol CloudsMixin: GameMixin {
}

extension CloudsMixin {
    var gameDocumentBase: GameDocumentBase { return CloudsDocument.sharedInstance }
    var gameDocument: CloudsDocument { return CloudsDocument.sharedInstance }
}
