//
//  LiarLiarMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LiarLiarMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LiarLiarDocument.sharedInstance }
}

class LiarLiarOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LiarLiarDocument.sharedInstance }
}

class LiarLiarHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LiarLiarDocument.sharedInstance }
}
