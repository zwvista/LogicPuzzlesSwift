//
//  LightenUpMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LightenUpMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LightenUpDocument.sharedInstance }
}

class LightenUpOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LightenUpDocument.sharedInstance }
}

class LightenUpHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LightenUpDocument.sharedInstance }
}
