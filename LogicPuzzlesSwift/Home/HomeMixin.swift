//
//  HomeMixin.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol HomeMixin {
    var gameDocument: HomeDocument { get }
    var gameOptions: HomeGameProgress { get }
    var soundManager: SoundManager { get }
}

extension HomeMixin {
    var gameDocument: HomeDocument { return HomeDocument.sharedInstance }
    var gameOptions: HomeGameProgress { return gameDocument.gameProgress }
    var soundManager: SoundManager { return SoundManager.sharedInstance }
}
