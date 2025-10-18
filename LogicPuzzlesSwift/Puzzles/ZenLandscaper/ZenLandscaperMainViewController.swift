//
//  ZenLandscaperMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ZenLandscaperMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ZenLandscaperDocument.sharedInstance }
}

class ZenLandscaperOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ZenLandscaperDocument.sharedInstance }
}

class ZenLandscaperHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ZenLandscaperDocument.sharedInstance }
}
