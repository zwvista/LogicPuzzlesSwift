//
//  WildlifeParkMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class WildlifeParkMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { WildlifeParkDocument.sharedInstance }
}

class WildlifeParkOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { WildlifeParkDocument.sharedInstance }
}

class WildlifeParkHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { WildlifeParkDocument.sharedInstance }
}
