//
//  PicnicMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PicnicMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PicnicDocument.sharedInstance }
}

class PicnicOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PicnicDocument.sharedInstance }
}

class PicnicHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PicnicDocument.sharedInstance }
}
