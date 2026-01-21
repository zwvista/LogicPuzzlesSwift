//
//  SlitherCornerMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SlitherCornerMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherCornerDocument.sharedInstance }
}

class SlitherCornerOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherCornerDocument.sharedInstance }
}

class SlitherCornerHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { SlitherCornerDocument.sharedInstance }
}
