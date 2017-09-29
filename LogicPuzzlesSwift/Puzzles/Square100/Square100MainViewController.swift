//
//  Square100MainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class Square100MainViewController: GameMainViewController {

    var gameDocument: Square100Document { return Square100Document.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return Square100Document.sharedInstance }

}
