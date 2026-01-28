//
//  LineSweeperMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LineSweeperMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LineSweeperDocument.sharedInstance }
}

class LineSweeperOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LineSweeperDocument.sharedInstance }
}

class LineSweeperHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LineSweeperDocument.sharedInstance }
}
