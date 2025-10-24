//
//  LandscaperMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LandscaperMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LandscaperDocument.sharedInstance }
}

class LandscaperOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LandscaperDocument.sharedInstance }
}

class LandscaperHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LandscaperDocument.sharedInstance }
}
