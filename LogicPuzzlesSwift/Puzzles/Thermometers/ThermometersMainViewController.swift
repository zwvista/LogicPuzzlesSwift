//
//  ThermometersMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ThermometersMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ThermometersDocument.sharedInstance }
}

class ThermometersOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ThermometersDocument.sharedInstance }
}

class ThermometersHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ThermometersDocument.sharedInstance }
}
