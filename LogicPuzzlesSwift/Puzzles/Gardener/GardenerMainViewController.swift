//
//  GardenerMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GardenerMainViewController: GameMainViewController {

    var gameDocument: GardenerDocument { return GardenerDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return GardenerDocument.sharedInstance }

}