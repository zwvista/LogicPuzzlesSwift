//
//  HiddenStarsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HiddenStarsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenStarsDocument.sharedInstance }
}

class HiddenStarsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenStarsDocument.sharedInstance }
}

class HiddenStarsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenStarsDocument.sharedInstance }
}
