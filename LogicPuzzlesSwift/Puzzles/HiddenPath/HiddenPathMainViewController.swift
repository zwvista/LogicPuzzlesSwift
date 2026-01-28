//
//  HiddenPathMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HiddenPathMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenPathDocument.sharedInstance }
}

class HiddenPathOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenPathDocument.sharedInstance }
}

class HiddenPathHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenPathDocument.sharedInstance }
}
