//
//  ParksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ParksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ParksDocument.sharedInstance }
}

class ParksOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ParksDocument.sharedInstance }
}

class ParksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ParksDocument.sharedInstance }
}
