//
//  MirrorsExtendedMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MirrorsExtendedMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsExtendedDocument.sharedInstance }
}

class MirrorsExtendedOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsExtendedDocument.sharedInstance }
}

class MirrorsExtendedHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MirrorsExtendedDocument.sharedInstance }
}
