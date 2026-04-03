//
//  SnakeIslandsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnakeIslandsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeIslandsDocument.sharedInstance }
}

class SnakeIslandsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeIslandsDocument.sharedInstance }
}

class SnakeIslandsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SnakeIslandsDocument.sharedInstance }
}
