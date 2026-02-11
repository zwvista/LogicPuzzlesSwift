//
//  YalooniqMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class YalooniqMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { YalooniqDocument.sharedInstance }
}

class YalooniqOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { YalooniqDocument.sharedInstance }
}

class YalooniqHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { YalooniqDocument.sharedInstance }
}
