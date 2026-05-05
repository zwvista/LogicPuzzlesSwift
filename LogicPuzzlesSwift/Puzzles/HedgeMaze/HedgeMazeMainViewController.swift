//
//  HedgeMazeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HedgeMazeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HedgeMazeDocument.sharedInstance }
}

class HedgeMazeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { HedgeMazeDocument.sharedInstance }
}

class HedgeMazeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HedgeMazeDocument.sharedInstance }
}
