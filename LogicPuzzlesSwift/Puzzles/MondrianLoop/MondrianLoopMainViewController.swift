//
//  MondrianLoopMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MondrianLoopMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MondrianLoopDocument.sharedInstance }
}

class MondrianLoopOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MondrianLoopDocument.sharedInstance }
}

class MondrianLoopHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MondrianLoopDocument.sharedInstance }
}
