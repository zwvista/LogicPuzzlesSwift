//
//  StraightAndBendLandsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class StraightAndBendLandsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { StraightAndBendLandsDocument.sharedInstance }
}

class StraightAndBendLandsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { StraightAndBendLandsDocument.sharedInstance }
}

class StraightAndBendLandsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { StraightAndBendLandsDocument.sharedInstance }
}
