//
//  AbstractPaintingMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class AbstractPaintingMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { AbstractPaintingDocument.sharedInstance }

}

class AbstractPaintingOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { AbstractPaintingDocument.sharedInstance }
    
}

class AbstractPaintingHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { AbstractPaintingDocument.sharedInstance }

}
