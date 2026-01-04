//
//  InsaneTatamisMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class InsaneTatamisMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { InsaneTatamisDocument.sharedInstance }
}

class InsaneTatamisOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { InsaneTatamisDocument.sharedInstance }
}

class InsaneTatamisHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { InsaneTatamisDocument.sharedInstance }
}
