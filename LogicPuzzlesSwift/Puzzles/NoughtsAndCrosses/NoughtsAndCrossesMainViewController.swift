//
//  NoughtsAndCrossesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NoughtsAndCrossesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NoughtsAndCrossesDocument.sharedInstance }
}

class NoughtsAndCrossesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { NoughtsAndCrossesDocument.sharedInstance }
}

class NoughtsAndCrossesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NoughtsAndCrossesDocument.sharedInstance }
}
