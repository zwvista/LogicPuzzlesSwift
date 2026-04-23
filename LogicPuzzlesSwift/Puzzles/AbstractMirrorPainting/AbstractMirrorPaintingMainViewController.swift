//
//  AbstractMirrorPaintingMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class AbstractMirrorPaintingMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { AbstractMirrorPaintingDocument.sharedInstance }
}

class AbstractMirrorPaintingOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { AbstractMirrorPaintingDocument.sharedInstance }
}

class AbstractMirrorPaintingHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { AbstractMirrorPaintingDocument.sharedInstance }
}
