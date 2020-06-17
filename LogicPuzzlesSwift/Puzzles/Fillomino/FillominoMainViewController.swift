//
//  FillominoMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FillominoMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { FillominoDocument.sharedInstance }

}

class FillominoOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { FillominoDocument.sharedInstance }

}

class FillominoHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { FillominoDocument.sharedInstance }

}
