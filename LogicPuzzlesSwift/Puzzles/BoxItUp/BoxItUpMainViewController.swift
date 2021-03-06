//
//  BoxItUpMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BoxItUpMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItUpDocument.sharedInstance }
}

class BoxItUpOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItUpDocument.sharedInstance }
}

class BoxItUpHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItUpDocument.sharedInstance }
}
