//
//  ZenGardensMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ZenGardensMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ZenGardensDocument.sharedInstance }
}

class ZenGardensOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ZenGardensDocument.sharedInstance }
}

class ZenGardensHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ZenGardensDocument.sharedInstance }
}
