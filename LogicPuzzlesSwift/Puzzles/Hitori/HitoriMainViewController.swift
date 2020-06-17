//
//  HitoriMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HitoriMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { HitoriDocument.sharedInstance }

}

class HitoriOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { HitoriDocument.sharedInstance }
    
}

class HitoriHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { HitoriDocument.sharedInstance }

}
