//
//  SukrokuroMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SukrokuroMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SukrokuroDocument.sharedInstance }
}

class SukrokuroOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SukrokuroDocument.sharedInstance }
}

class SukrokuroHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SukrokuroDocument.sharedInstance }
}
