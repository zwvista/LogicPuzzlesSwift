//
//  DigitalPathMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DigitalPathMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { DigitalPathDocument.sharedInstance }
}

class DigitalPathOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { DigitalPathDocument.sharedInstance }
}

class DigitalPathHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { DigitalPathDocument.sharedInstance }
}
