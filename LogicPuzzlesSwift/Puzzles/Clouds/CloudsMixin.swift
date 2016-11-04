//
//  CloudsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol CloudsMixin: GameMixin {
    var gameDocument: CloudsDocument { get }
    var gameOptions: CloudsGameProgress { get }
}

extension CloudsMixin {
    var gameDocument: CloudsDocument { return CloudsDocument.sharedInstance }
    var gameOptions: CloudsGameProgress { return gameDocument.gameProgress }
}
