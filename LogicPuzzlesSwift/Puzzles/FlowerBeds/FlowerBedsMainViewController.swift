//
//  FlowerBedsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FlowerBedsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerBedsDocument.sharedInstance }
}

class FlowerBedsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerBedsDocument.sharedInstance }
}

class FlowerBedsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerBedsDocument.sharedInstance }
}
