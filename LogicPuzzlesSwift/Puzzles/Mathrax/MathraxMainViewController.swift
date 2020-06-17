//
//  MathraxMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MathraxMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { MathraxDocument.sharedInstance }

}

class MathraxOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { MathraxDocument.sharedInstance }

}

class MathraxHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { MathraxDocument.sharedInstance }

}
