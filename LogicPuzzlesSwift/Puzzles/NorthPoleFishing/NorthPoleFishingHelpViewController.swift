//
//  NorthPoleFishingHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class NorthPoleFishingHelpViewController: GameHelpViewController {

    var gameDocument: NorthPoleFishingDocument { return NorthPoleFishingDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return NorthPoleFishingDocument.sharedInstance }

}