//
//  OrchardsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OrchardsMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { OrchardsDocument.sharedInstance }

}

class OrchardsOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { OrchardsDocument.sharedInstance }

}

class OrchardsHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { OrchardsDocument.sharedInstance }

}
