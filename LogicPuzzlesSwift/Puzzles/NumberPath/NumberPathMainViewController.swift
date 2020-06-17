//
//  NumberPathMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberPathMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NumberPathDocument.sharedInstance }
}

class NumberPathOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { NumberPathDocument.sharedInstance }
}

class NumberPathHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NumberPathDocument.sharedInstance }
}
