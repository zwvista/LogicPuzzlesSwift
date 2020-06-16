//
//  Square100OptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class Square100OptionsViewController: GameOptionsViewController {

    var gameDocument: Square100Document { Square100Document.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { Square100Document.sharedInstance }
    
}
