//
//  LakesAndMeadowsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LakesAndMeadowsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { LakesAndMeadowsDocument.sharedInstance }
}

class LakesAndMeadowsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { LakesAndMeadowsDocument.sharedInstance }
}

class LakesAndMeadowsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { LakesAndMeadowsDocument.sharedInstance }
}
