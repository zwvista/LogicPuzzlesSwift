//
//  LightBattleShipsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightBattleShipsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LightBattleShipsDocument.sharedInstance }
}

class LightBattleShipsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LightBattleShipsDocument.sharedInstance }
}

class LightBattleShipsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LightBattleShipsDocument.sharedInstance }
}
