//
//  NumberCrossingMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberCrossingMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NumberCrossingDocument.sharedInstance }
}

class NumberCrossingOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { NumberCrossingDocument.sharedInstance }
}

class NumberCrossingHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NumberCrossingDocument.sharedInstance }
}
