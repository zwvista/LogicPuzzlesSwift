//
//  MineShipsHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class MineShipsHelpViewController: GameHelpViewController {

    var gameDocument: MineShipsDocument { MineShipsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { MineShipsDocument.sharedInstance }

}
