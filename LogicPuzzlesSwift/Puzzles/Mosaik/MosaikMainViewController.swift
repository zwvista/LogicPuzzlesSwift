//
//  MosaikMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MosaikMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { MosaikDocument.sharedInstance }
}

class MosaikOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { MosaikDocument.sharedInstance }
}

class MosaikHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { MosaikDocument.sharedInstance }
}
