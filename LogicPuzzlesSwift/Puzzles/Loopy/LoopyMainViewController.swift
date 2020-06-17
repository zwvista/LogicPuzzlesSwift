//
//  LoopyMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LoopyMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { LoopyDocument.sharedInstance }

}

class LoopyOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { LoopyDocument.sharedInstance }
    
}

class LoopyHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { LoopyDocument.sharedInstance }

}
