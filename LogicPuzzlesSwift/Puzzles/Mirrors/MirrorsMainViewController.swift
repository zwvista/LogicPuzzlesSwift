//
//  MirrorsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MirrorsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsDocument.sharedInstance }
}

class MirrorsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsDocument.sharedInstance }
}

class MirrorsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsDocument.sharedInstance }
}
