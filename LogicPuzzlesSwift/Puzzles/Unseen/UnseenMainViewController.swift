//
//  UnseenMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class UnseenMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { UnseenDocument.sharedInstance }
}

class UnseenOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { UnseenDocument.sharedInstance }
}

class UnseenHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { UnseenDocument.sharedInstance }
}
