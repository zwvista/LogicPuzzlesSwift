//
//  BotanicalParkMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BotanicalParkMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BotanicalParkDocument.sharedInstance }
}

class BotanicalParkOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BotanicalParkDocument.sharedInstance }
}

class BotanicalParkHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BotanicalParkDocument.sharedInstance }
}
