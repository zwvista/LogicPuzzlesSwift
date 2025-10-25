//
//  ArchipelagoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ArchipelagoMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ArchipelagoDocument.sharedInstance }
}

class ArchipelagoOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ArchipelagoDocument.sharedInstance }
}

class ArchipelagoHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ArchipelagoDocument.sharedInstance }
}
