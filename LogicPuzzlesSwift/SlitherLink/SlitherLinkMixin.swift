//
//  SlitherLinkMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol SlitherLinkMixin {
    var gameDocument: SlitherLinkDocument { get }
    var gameOptions: SlitherLinkGameProgress { get }
    var soundManager: SoundManager { get }
}

extension SlitherLinkMixin {
    var gameDocument: SlitherLinkDocument { return SlitherLinkDocument.sharedInstance }
    var gameOptions: SlitherLinkGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
