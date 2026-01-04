//
//  FreePlanksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FreePlanksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FreePlanksDocument.sharedInstance }
}

class FreePlanksOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FreePlanksDocument.sharedInstance }
}

class FreePlanksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FreePlanksDocument.sharedInstance }
}
