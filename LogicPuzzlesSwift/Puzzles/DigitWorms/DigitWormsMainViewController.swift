//
//  DigitWormsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DigitWormsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { DigitWormsDocument.sharedInstance }
}

class DigitWormsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { DigitWormsDocument.sharedInstance }
}

class DigitWormsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { DigitWormsDocument.sharedInstance }
}
