//
//  NumberLinkMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberLinkMainViewController: GameMainViewController {

    var gameDocument: NumberLinkDocument { NumberLinkDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { NumberLinkDocument.sharedInstance }

}
