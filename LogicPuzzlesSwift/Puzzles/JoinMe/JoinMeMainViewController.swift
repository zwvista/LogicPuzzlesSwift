//
//  JoinMeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class JoinMeMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { JoinMeDocument.sharedInstance }
}

class JoinMeOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { JoinMeDocument.sharedInstance }
}

class JoinMeHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { JoinMeDocument.sharedInstance }
}
