//
//  NewCarpenterSquareMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NewCarpenterSquareMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NewCarpenterSquareDocument.sharedInstance }
}

class NewCarpenterSquareOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { NewCarpenterSquareDocument.sharedInstance }
}

class NewCarpenterSquareHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NewCarpenterSquareDocument.sharedInstance }
}
