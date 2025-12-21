//
//  RomeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RomeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { RomeDocument.sharedInstance }
}

class RomeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { RomeDocument.sharedInstance }
}

class RomeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { RomeDocument.sharedInstance }
}
