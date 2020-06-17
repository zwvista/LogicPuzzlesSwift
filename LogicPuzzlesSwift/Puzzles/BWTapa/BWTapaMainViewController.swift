//
//  BWTapaMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class BWTapaMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { BWTapaDocument.sharedInstance }

}

class BWTapaOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { BWTapaDocument.sharedInstance }
    
}

class BWTapaHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { BWTapaDocument.sharedInstance }

}
