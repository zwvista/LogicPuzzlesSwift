//
//  OverUnderMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OverUnderMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { OverUnderDocument.sharedInstance }

}

class OverUnderOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { OverUnderDocument.sharedInstance }
    
}

class OverUnderHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { OverUnderDocument.sharedInstance }

}
