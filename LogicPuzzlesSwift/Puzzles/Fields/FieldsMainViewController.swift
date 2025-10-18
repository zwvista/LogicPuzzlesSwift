//
//  FieldsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FieldsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FieldsDocument.sharedInstance }
}

class FieldsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FieldsDocument.sharedInstance }
}

class FieldsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FieldsDocument.sharedInstance }
}
