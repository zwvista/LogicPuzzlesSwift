//
//  SnakeominoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeominoMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeominoDocument.sharedInstance }
}

class SnakeominoOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeominoDocument.sharedInstance }
}

class SnakeominoHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeominoDocument.sharedInstance }
}
