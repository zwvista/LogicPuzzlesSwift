//
//  SnakeMazeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeMazeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeMazeDocument.sharedInstance }
}

class SnakeMazeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeMazeDocument.sharedInstance }
}

class SnakeMazeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeMazeDocument.sharedInstance }
}
