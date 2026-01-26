//
//  MineSlitherMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MineSlitherMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MineSlitherDocument.sharedInstance }
}

class MineSlitherOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MineSlitherDocument.sharedInstance }
}

class MineSlitherHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MineSlitherDocument.sharedInstance }
}
