//
//  HidokuMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HidokuMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HidokuDocument.sharedInstance }
}

class HidokuOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { HidokuDocument.sharedInstance }
}

class HidokuHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HidokuDocument.sharedInstance }
}
