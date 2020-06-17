//
//  FourMeNotMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FourMeNotMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FourMeNotDocument.sharedInstance }
}

class FourMeNotOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FourMeNotDocument.sharedInstance }
}

class FourMeNotHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FourMeNotDocument.sharedInstance }
}
