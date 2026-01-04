//
//  WishSandwichMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WishSandwichMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { WishSandwichDocument.sharedInstance }
}

class WishSandwichOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { WishSandwichDocument.sharedInstance }
}

class WishSandwichHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { WishSandwichDocument.sharedInstance }
}
