//
//  CoffeeAndSugarMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CoffeeAndSugarMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CoffeeAndSugarDocument.sharedInstance }
}

class CoffeeAndSugarOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CoffeeAndSugarDocument.sharedInstance }
}

class CoffeeAndSugarHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CoffeeAndSugarDocument.sharedInstance }
}
