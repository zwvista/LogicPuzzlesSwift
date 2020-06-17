//
//  TapDifferentlyMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TapDifferentlyMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TapDifferentlyDocument.sharedInstance }
}

class TapDifferentlyOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TapDifferentlyDocument.sharedInstance }
}

class TapDifferentlyHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TapDifferentlyDocument.sharedInstance }
}
