//
//  TentsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TentsMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { TentsDocument.sharedInstance }

}

class TentsOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { TentsDocument.sharedInstance }
    
}

class TentsHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { TentsDocument.sharedInstance }

}
