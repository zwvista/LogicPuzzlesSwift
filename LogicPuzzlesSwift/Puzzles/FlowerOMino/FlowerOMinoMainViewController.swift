//
//  FlowerOMinoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FlowerOMinoMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerOMinoDocument.sharedInstance }
}

class FlowerOMinoOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerOMinoDocument.sharedInstance }
}

class FlowerOMinoHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerOMinoDocument.sharedInstance }
}
