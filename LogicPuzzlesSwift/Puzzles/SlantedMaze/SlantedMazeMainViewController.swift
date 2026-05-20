//
//  SlantedMazeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlantedMazeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SlantedMazeDocument.sharedInstance }
}

class SlantedMazeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SlantedMazeDocument.sharedInstance }
}

class SlantedMazeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SlantedMazeDocument.sharedInstance }
}
