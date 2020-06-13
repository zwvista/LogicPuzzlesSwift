//
//  KropkiMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class KropkiMainViewController: GameMainViewController {

    var gameDocument: KropkiDocument { KropkiDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { KropkiDocument.sharedInstance }

}
