//
//  GalaxiesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GalaxiesMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { GalaxiesDocument.sharedInstance }

}

class GalaxiesOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { GalaxiesDocument.sharedInstance }
    
}

class GalaxiesHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { GalaxiesDocument.sharedInstance }

}
