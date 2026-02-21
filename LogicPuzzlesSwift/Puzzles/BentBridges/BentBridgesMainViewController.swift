//
//  BentBridgesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BentBridgesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BentBridgesDocument.sharedInstance }
}

class BentBridgesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BentBridgesDocument.sharedInstance }
}

class BentBridgesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BentBridgesDocument.sharedInstance }
}
