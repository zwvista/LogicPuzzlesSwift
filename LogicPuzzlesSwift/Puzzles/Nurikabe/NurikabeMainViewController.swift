//
//  NurikabeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NurikabeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NurikabeDocument.sharedInstance }
}

class NurikabeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { NurikabeDocument.sharedInstance }
}

class NurikabeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NurikabeDocument.sharedInstance }
}
