//
//  ChocolateMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ChocolateMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ChocolateDocument.sharedInstance }
}

class ChocolateOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ChocolateDocument.sharedInstance }
}

class ChocolateHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ChocolateDocument.sharedInstance }
}
