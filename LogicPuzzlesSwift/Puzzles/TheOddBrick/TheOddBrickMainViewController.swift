//
//  TheOddBrickMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheOddBrickMainViewController: GameMainViewController {

    var gameDocument: TheOddBrickDocument { TheOddBrickDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { TheOddBrickDocument.sharedInstance }

}
