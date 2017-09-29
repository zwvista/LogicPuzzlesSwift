//
//  Square100HelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class Square100HelpViewController: GameHelpViewController {

    var gameDocument: Square100Document { return Square100Document.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return Square100Document.sharedInstance }

}
