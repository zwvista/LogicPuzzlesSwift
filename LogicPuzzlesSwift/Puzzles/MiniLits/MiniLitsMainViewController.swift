//
//  MiniLitsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MiniLitsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MiniLitsDocument.sharedInstance }
}

class MiniLitsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MiniLitsDocument.sharedInstance }
}

class MiniLitsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MiniLitsDocument.sharedInstance }
}
