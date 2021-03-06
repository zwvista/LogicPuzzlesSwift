//
//  RobotFencesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RobotFencesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { RobotFencesDocument.sharedInstance }
}

class RobotFencesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { RobotFencesDocument.sharedInstance }
}

class RobotFencesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { RobotFencesDocument.sharedInstance }
}
