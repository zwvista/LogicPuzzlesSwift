//
//  PondsAndFlowerbedsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PondsAndFlowerbedsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PondsAndFlowerbedsDocument.sharedInstance }
}

class PondsAndFlowerbedsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PondsAndFlowerbedsDocument.sharedInstance }
}

class PondsAndFlowerbedsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PondsAndFlowerbedsDocument.sharedInstance }
}
