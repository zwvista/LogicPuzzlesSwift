//
//  TraceNumbersMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TraceNumbersMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TraceNumbersDocument.sharedInstance }
}

class TraceNumbersOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TraceNumbersDocument.sharedInstance }
}

class TraceNumbersHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TraceNumbersDocument.sharedInstance }
}
