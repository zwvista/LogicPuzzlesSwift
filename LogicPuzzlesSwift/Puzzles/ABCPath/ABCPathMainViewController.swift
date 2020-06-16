//
//  ABCPathMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ABCPathMainViewController: GameMainViewController {

    var gameDocument: ABCPathDocument { ABCPathDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { ABCPathDocument.sharedInstance }

}
