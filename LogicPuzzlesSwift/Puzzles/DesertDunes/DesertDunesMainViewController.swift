//
//  DesertDunesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DesertDunesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { DesertDunesDocument.sharedInstance }
}

class DesertDunesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { DesertDunesDocument.sharedInstance }
}

class DesertDunesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { DesertDunesDocument.sharedInstance }
}
