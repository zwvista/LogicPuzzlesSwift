//
//  RunInALoopMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RunInALoopMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { RunInALoopDocument.sharedInstance }
}

class RunInALoopOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { RunInALoopDocument.sharedInstance }
}

class RunInALoopHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { RunInALoopDocument.sharedInstance }
}
