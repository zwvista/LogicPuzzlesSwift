//
//  ArrowsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ArrowsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ArrowsDocument.sharedInstance }
}

class ArrowsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ArrowsDocument.sharedInstance }
}

class ArrowsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ArrowsDocument.sharedInstance }
}
