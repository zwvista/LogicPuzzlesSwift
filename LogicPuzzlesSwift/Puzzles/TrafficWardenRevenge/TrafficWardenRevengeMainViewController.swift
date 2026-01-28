//
//  TrafficWardenRevengeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TrafficWardenRevengeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TrafficWardenRevengeDocument.sharedInstance }
}

class TrafficWardenRevengeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TrafficWardenRevengeDocument.sharedInstance }
}

class TrafficWardenRevengeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TrafficWardenRevengeDocument.sharedInstance }
}
