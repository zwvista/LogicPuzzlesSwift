//
//  TheMagicNumberMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheMagicNumberMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TheMagicNumberDocument.sharedInstance }
}

class TheMagicNumberOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TheMagicNumberDocument.sharedInstance }
}

class TheMagicNumberHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TheMagicNumberDocument.sharedInstance }
}
