//
//  LighthousesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LighthousesMainViewController: GameMainViewController, LighthousesMixin {
    
    override func startGame(_ sender: AnyObject) {
        gameDocument.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumGame(self)
    }
    
    override func resumGame(_ sender: AnyObject) {
        gameDocument.resumeGame()
        resumeGame()
    }
}
