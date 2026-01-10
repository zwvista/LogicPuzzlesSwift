//
//  HiddenCloudsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HiddenCloudsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenCloudsDocument.sharedInstance }
}

class HiddenCloudsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenCloudsDocument.sharedInstance }
}

class HiddenCloudsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { HiddenCloudsDocument.sharedInstance }
}
