//
//  RoomsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RoomsMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { RoomsDocument.sharedInstance }

}

class RoomsOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { RoomsDocument.sharedInstance }
    
}

class RoomsHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { RoomsDocument.sharedInstance }

}
