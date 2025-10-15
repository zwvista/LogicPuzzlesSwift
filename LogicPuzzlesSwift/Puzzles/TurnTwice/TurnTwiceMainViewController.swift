//
//  TurnTwiceMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TurnTwiceMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TurnTwiceDocument.sharedInstance }
}

class TurnTwiceOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TurnTwiceDocument.sharedInstance }
}

class TurnTwiceHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TurnTwiceDocument.sharedInstance }
}
