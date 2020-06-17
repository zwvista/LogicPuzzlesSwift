//
//  KakuroMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KakuroMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { KakuroDocument.sharedInstance }
}

class KakuroOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { KakuroDocument.sharedInstance }
}

class KakuroHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { KakuroDocument.sharedInstance }
}
