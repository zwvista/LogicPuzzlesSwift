//
//  FenceItUpMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FenceItUpMainViewController: GameMainViewController {

    var gameDocument: FenceItUpDocument { FenceItUpDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { FenceItUpDocument.sharedInstance }

}
