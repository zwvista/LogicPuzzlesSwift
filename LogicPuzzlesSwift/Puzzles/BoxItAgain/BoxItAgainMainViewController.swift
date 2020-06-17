//
//  BoxItAgainMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BoxItAgainMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItAgainDocument.sharedInstance }
}

class BoxItAgainOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItAgainDocument.sharedInstance }
}

class BoxItAgainHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { BoxItAgainDocument.sharedInstance }
}
