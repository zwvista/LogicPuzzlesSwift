//
//  CastlePatrolMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CastlePatrolMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CastlePatrolDocument.sharedInstance }
}

class CastlePatrolOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CastlePatrolDocument.sharedInstance }
}

class CastlePatrolHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CastlePatrolDocument.sharedInstance }
}
