//
//  TentsHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class TentsHelpViewController: GameHelpViewController {

    var gameDocument: TentsDocument { TentsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { TentsDocument.sharedInstance }

}
