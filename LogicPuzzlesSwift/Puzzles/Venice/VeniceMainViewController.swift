//
//  VeniceMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class VeniceMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { VeniceDocument.sharedInstance }
}

class VeniceOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { VeniceDocument.sharedInstance }
}

class VeniceHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { VeniceDocument.sharedInstance }
}
