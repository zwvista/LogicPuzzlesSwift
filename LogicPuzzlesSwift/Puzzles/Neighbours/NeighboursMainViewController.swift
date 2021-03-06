//
//  NeighboursMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NeighboursMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NeighboursDocument.sharedInstance }
}

class NeighboursOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { NeighboursDocument.sharedInstance }
}

class NeighboursHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NeighboursDocument.sharedInstance }
}
