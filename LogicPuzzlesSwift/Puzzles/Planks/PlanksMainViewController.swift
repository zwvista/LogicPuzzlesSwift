//
//  PlanksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PlanksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PlanksDocument.sharedInstance }
}

class PlanksOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PlanksDocument.sharedInstance }
}

class PlanksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PlanksDocument.sharedInstance }
}
