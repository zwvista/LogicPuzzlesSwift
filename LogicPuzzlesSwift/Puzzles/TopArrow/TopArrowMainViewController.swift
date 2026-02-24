//
//  TopArrowMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TopArrowMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TopArrowDocument.sharedInstance }
}

class TopArrowOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TopArrowDocument.sharedInstance }
}

class TopArrowHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TopArrowDocument.sharedInstance }
}
