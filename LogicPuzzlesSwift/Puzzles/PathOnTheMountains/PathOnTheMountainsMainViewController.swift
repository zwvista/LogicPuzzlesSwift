//
//  PathOnTheMountainsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PathOnTheMountainsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { PathOnTheMountainsDocument.sharedInstance }
}

class PathOnTheMountainsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { PathOnTheMountainsDocument.sharedInstance }
}

class PathOnTheMountainsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { PathOnTheMountainsDocument.sharedInstance }
}
