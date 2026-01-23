//
//  OnlyStraightsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OnlyStraightsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { OnlyStraightsDocument.sharedInstance }
}

class OnlyStraightsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { OnlyStraightsDocument.sharedInstance }
}

class OnlyStraightsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { OnlyStraightsDocument.sharedInstance }
}
