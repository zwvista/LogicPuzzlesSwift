//
//  MakeTheDifferenceMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MakeTheDifferenceMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MakeTheDifferenceDocument.sharedInstance }
}

class MakeTheDifferenceOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MakeTheDifferenceDocument.sharedInstance }
}

class MakeTheDifferenceHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MakeTheDifferenceDocument.sharedInstance }
}
