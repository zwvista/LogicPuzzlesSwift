//
//  PouringWaterMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PouringWaterMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PouringWaterDocument.sharedInstance }
}

class PouringWaterOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PouringWaterDocument.sharedInstance }
}

class PouringWaterHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PouringWaterDocument.sharedInstance }
}
