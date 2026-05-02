//
//  FarmerMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FarmerMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FarmerDocument.sharedInstance }
}

class FarmerOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FarmerDocument.sharedInstance }
}

class FarmerHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FarmerDocument.sharedInstance }
}
