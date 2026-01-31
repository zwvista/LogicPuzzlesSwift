//
//  PointingMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PointingMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PointingDocument.sharedInstance }
}

class PointingOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PointingDocument.sharedInstance }
}

class PointingHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PointingDocument.sharedInstance }
}
