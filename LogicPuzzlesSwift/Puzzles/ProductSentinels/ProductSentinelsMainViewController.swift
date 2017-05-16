//
//  ProductSentinelsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ProductSentinelsMainViewController: GameMainViewController {

    var gameDocument: ProductSentinelsDocument { return ProductSentinelsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return ProductSentinelsDocument.sharedInstance }

    override func startGame(_ sender: UIButton) {
        gameDocument.selectedLevelID = sender.titleLabel!.text!
        resumGame(self)
    }
    
    override func resumGame(_ sender: Any) {
        gameDocument.resumeGame()
        resumeGame()
    }
}
