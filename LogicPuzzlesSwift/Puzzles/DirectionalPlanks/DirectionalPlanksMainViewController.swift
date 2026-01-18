//
//  DirectionalPlanksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DirectionalPlanksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { DirectionalPlanksDocument.sharedInstance }
}

class DirectionalPlanksOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { DirectionalPlanksDocument.sharedInstance }
}

class DirectionalPlanksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { DirectionalPlanksDocument.sharedInstance }
}
