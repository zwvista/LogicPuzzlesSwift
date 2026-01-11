//
//  FloorPlanMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FloorPlanMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FloorPlanDocument.sharedInstance }
}

class FloorPlanOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FloorPlanDocument.sharedInstance }
}

class FloorPlanHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FloorPlanDocument.sharedInstance }
}
