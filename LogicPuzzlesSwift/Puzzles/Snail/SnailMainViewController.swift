//
//  SnailMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SnailMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SnailDocument.sharedInstance }
}

class SnailOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SnailDocument.sharedInstance }
}

class SnailHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SnailDocument.sharedInstance }
}
