//
//  GemsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GemsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { GemsDocument.sharedInstance }
}

class GemsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { GemsDocument.sharedInstance }
}

class GemsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { GemsDocument.sharedInstance }
}
