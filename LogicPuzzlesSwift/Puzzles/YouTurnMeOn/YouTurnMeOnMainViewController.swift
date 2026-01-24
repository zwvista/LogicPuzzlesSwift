//
//  YouTurnMeOnMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class YouTurnMeOnMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { YouTurnMeOnDocument.sharedInstance }
}

class YouTurnMeOnOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { YouTurnMeOnDocument.sharedInstance }
}

class YouTurnMeOnHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { YouTurnMeOnDocument.sharedInstance }
}
