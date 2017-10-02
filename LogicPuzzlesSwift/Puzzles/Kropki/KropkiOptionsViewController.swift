//
//  KropkiOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KropkiOptionsViewController: GameOptionsViewController {

    var gameDocument: KropkiDocument { return KropkiDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return KropkiDocument.sharedInstance }
    
}
