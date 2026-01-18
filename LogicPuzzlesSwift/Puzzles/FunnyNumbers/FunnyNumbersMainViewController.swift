//
//  FunnyNumbersMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FunnyNumbersMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FunnyNumbersDocument.sharedInstance }
}

class FunnyNumbersOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FunnyNumbersDocument.sharedInstance }
}

class FunnyNumbersHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FunnyNumbersDocument.sharedInstance }
}
