//
//  RippleEffectMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RippleEffectMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { RippleEffectDocument.sharedInstance }
}

class RippleEffectOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { RippleEffectDocument.sharedInstance }
}

class RippleEffectHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { RippleEffectDocument.sharedInstance }
}
