//
//  HeliumAndIronMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HeliumAndIronMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HeliumAndIronDocument.sharedInstance }
}

class HeliumAndIronOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { HeliumAndIronDocument.sharedInstance }
}

class HeliumAndIronHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HeliumAndIronDocument.sharedInstance }
}
