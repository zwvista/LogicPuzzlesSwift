//
//  LightBattleShipsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightBattleShipsMainViewController: GameMainViewController {

    var gameDocument: LightBattleShipsDocument { return LightBattleShipsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return LightBattleShipsDocument.sharedInstance }

    override func startGame(_ sender: UIButton) {
        gameDocument.selectedLevelID = sender.titleLabel!.text!
        resumGame(self)
    }
    
    override func resumGame(_ sender: Any) {
        gameDocument.resumeGame()
        resumeGame()
    }
}
