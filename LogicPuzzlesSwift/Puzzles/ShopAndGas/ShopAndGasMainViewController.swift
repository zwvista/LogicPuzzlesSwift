//
//  ShopAndGasMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ShopAndGasMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ShopAndGasDocument.sharedInstance }
}

class ShopAndGasOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ShopAndGasDocument.sharedInstance }
}

class ShopAndGasHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ShopAndGasDocument.sharedInstance }
}
