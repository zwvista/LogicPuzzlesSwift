//
//  TetrominoPegsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TetrominoPegsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TetrominoPegsDocument.sharedInstance }
}

class TetrominoPegsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TetrominoPegsDocument.sharedInstance }
}

class TetrominoPegsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TetrominoPegsDocument.sharedInstance }
}
