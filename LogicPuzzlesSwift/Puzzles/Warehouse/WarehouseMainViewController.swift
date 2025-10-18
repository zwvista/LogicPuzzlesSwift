//
//  WarehouseMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WarehouseMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { WarehouseDocument.sharedInstance }
}

class WarehouseOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { WarehouseDocument.sharedInstance }
}

class WarehouseHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { WarehouseDocument.sharedInstance }
}
