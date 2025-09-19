//
//  MaketheDifferenceMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MaketheDifferenceMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MaketheDifferenceDocument.sharedInstance }
}

class MaketheDifferenceOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MaketheDifferenceDocument.sharedInstance }
}

class MaketheDifferenceHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MaketheDifferenceDocument.sharedInstance }
}
