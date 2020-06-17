//
//  TatamiMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TatamiMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TatamiDocument.sharedInstance }
}

class TatamiOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TatamiDocument.sharedInstance }
}

class TatamiHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TatamiDocument.sharedInstance }
}
