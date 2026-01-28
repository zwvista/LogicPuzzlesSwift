//
//  CleaningPathMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CleaningPathMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CleaningPathDocument.sharedInstance }
}

class CleaningPathOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CleaningPathDocument.sharedInstance }
}

class CleaningPathHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CleaningPathDocument.sharedInstance }
}
