//
//  WallSentinelsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WallSentinelsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { WallSentinelsDocument.sharedInstance }
}

class WallSentinelsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { WallSentinelsDocument.sharedInstance }
}

class WallSentinelsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { WallSentinelsDocument.sharedInstance }
}
