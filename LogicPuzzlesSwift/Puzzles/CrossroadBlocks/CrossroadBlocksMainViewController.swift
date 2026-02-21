//
//  CrossroadBlocksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CrossroadBlocksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadBlocksDocument.sharedInstance }
}

class CrossroadBlocksOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadBlocksDocument.sharedInstance }
}

class CrossroadBlocksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CrossroadBlocksDocument.sharedInstance }
}
