//
//  GalaxiesOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GalaxiesOptionsViewController: GameOptionsViewController {

    var gameDocument: GalaxiesDocument { GalaxiesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { GalaxiesDocument.sharedInstance }
    
}
