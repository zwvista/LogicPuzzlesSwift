//
//  SlitherLinkMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlitherLinkMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherLinkDocument.sharedInstance }
}

class SlitherLinkOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherLinkDocument.sharedInstance }
}

class SlitherLinkHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherLinkDocument.sharedInstance }
}
