//
//  SnakeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeDocument.sharedInstance }
}

class SnakeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeDocument.sharedInstance }
}

class SnakeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeDocument.sharedInstance }
}
