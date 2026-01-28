//
//  TrafficWardenMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TrafficWardenMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TrafficWardenDocument.sharedInstance }
}

class TrafficWardenOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { TrafficWardenDocument.sharedInstance }
}

class TrafficWardenHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TrafficWardenDocument.sharedInstance }
}
