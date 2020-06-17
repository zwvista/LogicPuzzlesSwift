//
//  MasyuMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MasyuMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { MasyuDocument.sharedInstance }

}

class MasyuOptionsViewController: GameOptionsViewController {
    
    override func getGameDocument() -> GameDocumentBase { MasyuDocument.sharedInstance }
    
}

class MasyuHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { MasyuDocument.sharedInstance }

}
