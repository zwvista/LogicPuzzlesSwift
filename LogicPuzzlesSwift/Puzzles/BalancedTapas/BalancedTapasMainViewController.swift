//
//  BalancedTapasMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BalancedTapasMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BalancedTapasDocument.sharedInstance }
}

class BalancedTapasOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BalancedTapasDocument.sharedInstance }
}

class BalancedTapasHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BalancedTapasDocument.sharedInstance }
}
