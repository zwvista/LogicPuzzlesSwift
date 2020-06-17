//
//  BattleShipsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BattleShipsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BattleShipsDocument.sharedInstance }
}

class BattleShipsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BattleShipsDocument.sharedInstance }
}

class BattleShipsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BattleShipsDocument.sharedInstance }
}
