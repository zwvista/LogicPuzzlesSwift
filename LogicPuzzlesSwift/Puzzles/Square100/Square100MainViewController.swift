//
//  Square100MainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class Square100MainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { Square100Document.sharedInstance }

}

class Square100OptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { Square100Document.sharedInstance }
    
}

class Square100HelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { Square100Document.sharedInstance }

}
