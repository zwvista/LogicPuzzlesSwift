//
//  CloudsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsDocument.sharedInstance }
}

class CloudsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsDocument.sharedInstance }
}

class CloudsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CloudsDocument.sharedInstance }
}
