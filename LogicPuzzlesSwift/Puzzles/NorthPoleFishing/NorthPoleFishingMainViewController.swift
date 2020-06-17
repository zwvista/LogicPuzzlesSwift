//
//  NorthPoleFishingMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NorthPoleFishingMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { NorthPoleFishingDocument.sharedInstance }
}

class NorthPoleFishingOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { NorthPoleFishingDocument.sharedInstance }
}

class NorthPoleFishingHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { NorthPoleFishingDocument.sharedInstance }
}
