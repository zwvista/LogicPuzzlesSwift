//
//  BridgesOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BridgesOptionsViewController: GameOptionsViewController {
    
    var gameDocument: BridgesDocument { return BridgesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return BridgesDocument.sharedInstance }
    
}
