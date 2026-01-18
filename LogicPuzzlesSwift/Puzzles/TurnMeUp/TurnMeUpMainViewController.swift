//
//  TurnMeUpMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TurnMeUpMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TurnMeUpDocument.sharedInstance }
}

class TurnMeUpOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { TurnMeUpDocument.sharedInstance }
}

class TurnMeUpHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TurnMeUpDocument.sharedInstance }
}
