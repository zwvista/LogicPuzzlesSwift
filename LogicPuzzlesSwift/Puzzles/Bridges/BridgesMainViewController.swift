//
//  BridgesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BridgesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BridgesDocument.sharedInstance }
}

class BridgesOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { BridgesDocument.sharedInstance }
}

class BridgesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BridgesDocument.sharedInstance }
}
