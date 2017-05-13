//
//  ParksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ParksMainViewController: GameMainViewController, ParksMixin {
    
    override func startGame(_ sender: Any) {
        gameDocument.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumGame(self)
    }
    
    override func resumGame(_ sender: Any) {
        gameDocument.resumeGame()
        resumeGame()
    }
}
