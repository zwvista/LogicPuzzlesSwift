//
//  PlanetsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PlanetsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PlanetsDocument.sharedInstance }
}

class PlanetsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PlanetsDocument.sharedInstance }
}

class PlanetsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PlanetsDocument.sharedInstance }
}
