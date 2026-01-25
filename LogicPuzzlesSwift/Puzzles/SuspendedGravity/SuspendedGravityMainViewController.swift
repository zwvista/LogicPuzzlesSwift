//
//  SuspendedGravityMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SuspendedGravityMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SuspendedGravityDocument.sharedInstance }
}

class SuspendedGravityOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SuspendedGravityDocument.sharedInstance }
}

class SuspendedGravityHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SuspendedGravityDocument.sharedInstance }
}
