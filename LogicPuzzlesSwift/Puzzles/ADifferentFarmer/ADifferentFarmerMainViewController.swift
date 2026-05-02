//
//  ADifferentFarmerMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ADifferentFarmerMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ADifferentFarmerDocument.sharedInstance }
}

class ADifferentFarmerOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ADifferentFarmerDocument.sharedInstance }
}

class ADifferentFarmerHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ADifferentFarmerDocument.sharedInstance }
}
