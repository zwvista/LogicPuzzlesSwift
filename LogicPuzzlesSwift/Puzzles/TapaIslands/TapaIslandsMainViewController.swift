//
//  TapaIslandsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TapaIslandsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TapaIslandsDocument.sharedInstance }
}

class TapaIslandsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TapaIslandsDocument.sharedInstance }
}

class TapaIslandsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TapaIslandsDocument.sharedInstance }
}
