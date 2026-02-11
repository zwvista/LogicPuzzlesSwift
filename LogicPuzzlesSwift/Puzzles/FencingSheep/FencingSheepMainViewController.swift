//
//  FencingSheepMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FencingSheepMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FencingSheepDocument.sharedInstance }
}

class FencingSheepOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FencingSheepDocument.sharedInstance }
}

class FencingSheepHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FencingSheepDocument.sharedInstance }
}
