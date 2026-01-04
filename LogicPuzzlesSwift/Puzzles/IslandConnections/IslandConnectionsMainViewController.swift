//
//  IslandConnectionsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class IslandConnectionsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { IslandConnectionsDocument.sharedInstance }
}

class IslandConnectionsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { IslandConnectionsDocument.sharedInstance }
}

class IslandConnectionsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { IslandConnectionsDocument.sharedInstance }
}
