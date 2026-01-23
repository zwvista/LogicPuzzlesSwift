//
//  OnlyBendsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OnlyBendsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { OnlyBendsDocument.sharedInstance }
}

class OnlyBendsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { OnlyBendsDocument.sharedInstance }
}

class OnlyBendsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { OnlyBendsDocument.sharedInstance }
}
