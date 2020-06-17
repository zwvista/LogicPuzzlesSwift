//
//  TierraDelFuegoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TierraDelFuegoMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TierraDelFuegoDocument.sharedInstance }
}

class TierraDelFuegoOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TierraDelFuegoDocument.sharedInstance }
}

class TierraDelFuegoHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TierraDelFuegoDocument.sharedInstance }
}
