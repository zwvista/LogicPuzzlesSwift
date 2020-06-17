//
//  CalcudokuMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CalcudokuMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { CalcudokuDocument.sharedInstance }

}

class CalcudokuOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { CalcudokuDocument.sharedInstance }

}

class CalcudokuHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { CalcudokuDocument.sharedInstance }

}
