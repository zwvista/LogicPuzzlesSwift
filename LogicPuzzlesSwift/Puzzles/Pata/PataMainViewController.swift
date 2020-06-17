//
//  PataMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PataMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PataDocument.sharedInstance }
}

class PataOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { PataDocument.sharedInstance }
}

class PataHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PataDocument.sharedInstance }
}
