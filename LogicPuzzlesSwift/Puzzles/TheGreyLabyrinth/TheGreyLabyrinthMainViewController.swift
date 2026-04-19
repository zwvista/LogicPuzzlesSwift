//
//  TheGreyLabyrinthMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheGreyLabyrinthMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TheGreyLabyrinthDocument.sharedInstance }
}

class TheGreyLabyrinthOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TheGreyLabyrinthDocument.sharedInstance }
}

class TheGreyLabyrinthHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TheGreyLabyrinthDocument.sharedInstance }
}
