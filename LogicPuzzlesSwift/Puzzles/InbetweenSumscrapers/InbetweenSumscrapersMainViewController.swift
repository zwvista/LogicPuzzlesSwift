//
//  InbetweenSumscrapersMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class InbetweenSumscrapersMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenSumscrapersDocument.sharedInstance }
}

class InbetweenSumscrapersOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenSumscrapersDocument.sharedInstance }
}

class InbetweenSumscrapersHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { InbetweenSumscrapersDocument.sharedInstance }
}
