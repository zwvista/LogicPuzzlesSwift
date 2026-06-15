//
//  ScissorsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ScissorsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ScissorsDocument.sharedInstance }
}

class ScissorsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ScissorsDocument.sharedInstance }
}

class ScissorsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ScissorsDocument.sharedInstance }
}
