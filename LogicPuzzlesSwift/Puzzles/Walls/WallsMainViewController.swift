//
//  WallsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WallsMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { WallsDocument.sharedInstance }

}

class WallsOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { WallsDocument.sharedInstance }

}

class WallsHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { WallsDocument.sharedInstance }

}
