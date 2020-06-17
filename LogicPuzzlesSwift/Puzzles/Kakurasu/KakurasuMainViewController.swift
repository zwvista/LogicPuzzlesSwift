//
//  KakurasuMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KakurasuMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { KakurasuDocument.sharedInstance }
}

class KakurasuOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { KakurasuDocument.sharedInstance }
}

class KakurasuHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { KakurasuDocument.sharedInstance }
}
