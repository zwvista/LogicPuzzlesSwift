//
//  BranchesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BranchesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BranchesDocument.sharedInstance }
}

class BranchesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BranchesDocument.sharedInstance }
}

class BranchesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BranchesDocument.sharedInstance }
}
