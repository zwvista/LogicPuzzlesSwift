//
//  BanquetMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BanquetMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BanquetDocument.sharedInstance }
}

class BanquetOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BanquetDocument.sharedInstance }
}

class BanquetHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BanquetDocument.sharedInstance }
}
