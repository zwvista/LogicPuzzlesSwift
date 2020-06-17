//
//  PaintTheNurikabeMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class PaintTheNurikabeMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { PaintTheNurikabeDocument.sharedInstance }

}

class PaintTheNurikabeOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { PaintTheNurikabeDocument.sharedInstance }
    
}

class PaintTheNurikabeHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { PaintTheNurikabeDocument.sharedInstance }

}
