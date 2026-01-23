//
//  PathOnTheHillsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PathOnTheHillsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PathOnTheHillsDocument.sharedInstance }
}

class PathOnTheHillsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { PathOnTheHillsDocument.sharedInstance }
}

class PathOnTheHillsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PathOnTheHillsDocument.sharedInstance }
}
