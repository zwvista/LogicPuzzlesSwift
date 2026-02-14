//
//  CloudsAndClearsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsAndClearsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsAndClearsDocument.sharedInstance }
}

class CloudsAndClearsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsAndClearsDocument.sharedInstance }
}

class CloudsAndClearsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsAndClearsDocument.sharedInstance }
}
