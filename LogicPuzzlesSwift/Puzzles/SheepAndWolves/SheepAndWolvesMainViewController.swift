//
//  SheepAndWolvesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SheepAndWolvesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SheepAndWolvesDocument.sharedInstance }
}

class SheepAndWolvesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SheepAndWolvesDocument.sharedInstance }
}

class SheepAndWolvesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SheepAndWolvesDocument.sharedInstance }
}
