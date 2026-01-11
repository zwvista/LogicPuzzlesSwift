//
//  CulturedBranchesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CulturedBranchesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CulturedBranchesDocument.sharedInstance }
}

class CulturedBranchesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CulturedBranchesDocument.sharedInstance }
}

class CulturedBranchesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CulturedBranchesDocument.sharedInstance }
}
