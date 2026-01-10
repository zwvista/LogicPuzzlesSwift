//
//  TrebuchetMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TrebuchetMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TrebuchetDocument.sharedInstance }
}

class TrebuchetOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TrebuchetDocument.sharedInstance }
}

class TrebuchetHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TrebuchetDocument.sharedInstance }
}
