//
//  CrosstownTrafficMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CrosstownTrafficMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CrosstownTrafficDocument.sharedInstance }
}

class CrosstownTrafficOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CrosstownTrafficDocument.sharedInstance }
}

class CrosstownTrafficHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CrosstownTrafficDocument.sharedInstance }
}
