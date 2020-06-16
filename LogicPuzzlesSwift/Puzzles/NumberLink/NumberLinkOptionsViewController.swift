//
//  NumberLinkOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class NumberLinkOptionsViewController: GameOptionsViewController {
    
    var gameDocument: NumberLinkDocument { NumberLinkDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { NumberLinkDocument.sharedInstance }
    
}
