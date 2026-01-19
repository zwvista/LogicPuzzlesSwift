//
//  CrossroadsXMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CrossroadsXMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadsXDocument.sharedInstance }
}

class CrossroadsXOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadsXDocument.sharedInstance }
}

class CrossroadsXHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadsXDocument.sharedInstance }
}
