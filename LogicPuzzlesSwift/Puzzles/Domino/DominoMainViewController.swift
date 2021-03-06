//
//  DominoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DominoMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { DominoDocument.sharedInstance }
}

class DominoOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { DominoDocument.sharedInstance }
}

class DominoHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { DominoDocument.sharedInstance }
}
