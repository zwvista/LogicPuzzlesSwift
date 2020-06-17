//
//  FenceItUpMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FenceItUpMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FenceItUpDocument.sharedInstance }
}

class FenceItUpOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FenceItUpDocument.sharedInstance }
}

class FenceItUpHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FenceItUpDocument.sharedInstance }
}
