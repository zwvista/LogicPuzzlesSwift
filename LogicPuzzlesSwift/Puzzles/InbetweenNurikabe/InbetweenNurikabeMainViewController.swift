//
//  InbetweenNurikabeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class InbetweenNurikabeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenNurikabeDocument.sharedInstance }
}

class InbetweenNurikabeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenNurikabeDocument.sharedInstance }
}

class InbetweenNurikabeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenNurikabeDocument.sharedInstance }
}
