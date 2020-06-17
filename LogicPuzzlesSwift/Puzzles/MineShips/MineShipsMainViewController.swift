//
//  MineShipsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MineShipsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MineShipsDocument.sharedInstance }
}

class MineShipsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MineShipsDocument.sharedInstance }
}

class MineShipsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MineShipsDocument.sharedInstance }
}
