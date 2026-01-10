//
//  StepsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class StepsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { StepsDocument.sharedInstance }
}

class StepsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { StepsDocument.sharedInstance }
}

class StepsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { StepsDocument.sharedInstance }
}
