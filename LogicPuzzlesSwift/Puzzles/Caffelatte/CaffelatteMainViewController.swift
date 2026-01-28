//
//  CaffelatteMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CaffelatteMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CaffelatteDocument.sharedInstance }
}

class CaffelatteOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CaffelatteDocument.sharedInstance }
}

class CaffelatteHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CaffelatteDocument.sharedInstance }
}
