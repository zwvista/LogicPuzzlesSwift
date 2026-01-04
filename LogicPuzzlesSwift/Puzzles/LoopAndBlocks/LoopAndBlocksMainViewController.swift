//
//  LoopAndBlocksMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LoopAndBlocksMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LoopAndBlocksDocument.sharedInstance }
}

class LoopAndBlocksOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { LoopAndBlocksDocument.sharedInstance }
}

class LoopAndBlocksHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LoopAndBlocksDocument.sharedInstance }
}
