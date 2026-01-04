//
//  StraightAndTurnMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class StraightAndTurnMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { StraightAndTurnDocument.sharedInstance }
}

class StraightAndTurnOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { StraightAndTurnDocument.sharedInstance }
}

class StraightAndTurnHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { StraightAndTurnDocument.sharedInstance }
}
