//
//  AssemblyInstructionsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class AssemblyInstructionsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { AssemblyInstructionsDocument.sharedInstance }
}

class AssemblyInstructionsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { AssemblyInstructionsDocument.sharedInstance }
}

class AssemblyInstructionsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { AssemblyInstructionsDocument.sharedInstance }
}
