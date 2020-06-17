//
//  AbcMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class AbcMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { AbcDocument.sharedInstance }

}

class AbcOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { AbcDocument.sharedInstance }
    
}

class AbcHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { AbcDocument.sharedInstance }

}
