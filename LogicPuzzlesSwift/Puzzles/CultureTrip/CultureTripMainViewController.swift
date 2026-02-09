//
//  CultureTripMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CultureTripMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { CultureTripDocument.sharedInstance }
}

class CultureTripOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { CultureTripDocument.sharedInstance }
}

class CultureTripHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { CultureTripDocument.sharedInstance }
}
