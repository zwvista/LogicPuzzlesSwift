//
//  RabbitsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RabbitsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { RabbitsDocument.sharedInstance }
}

class RabbitsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { RabbitsDocument.sharedInstance }
}

class RabbitsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { RabbitsDocument.sharedInstance }
}
