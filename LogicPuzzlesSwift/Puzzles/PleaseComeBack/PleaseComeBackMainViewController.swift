//
//  PleaseComeBackMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PleaseComeBackMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PleaseComeBackDocument.sharedInstance }
}

class PleaseComeBackOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { PleaseComeBackDocument.sharedInstance }
}

class PleaseComeBackHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PleaseComeBackDocument.sharedInstance }
}
