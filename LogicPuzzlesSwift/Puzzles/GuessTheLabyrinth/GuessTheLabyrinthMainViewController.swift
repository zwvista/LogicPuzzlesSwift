//
//  GuessTheLabyrinthMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GuessTheLabyrinthMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { GuessTheLabyrinthDocument.sharedInstance }
}

class GuessTheLabyrinthOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { GuessTheLabyrinthDocument.sharedInstance }
}

class GuessTheLabyrinthHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { GuessTheLabyrinthDocument.sharedInstance }
}
