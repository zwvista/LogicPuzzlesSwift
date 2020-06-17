//
//  CarpentersSquareMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CarpentersSquareMainViewController: GameMainViewController {

    override func getGameDocument() -> GameDocumentBase { CarpentersSquareDocument.sharedInstance }

}

class CarpentersSquareOptionsViewController: GameOptionsViewController {

    override func getGameDocument() -> GameDocumentBase { CarpentersSquareDocument.sharedInstance }
    
}

class CarpentersSquareHelpViewController: GameHelpViewController {

    override func getGameDocument() -> GameDocumentBase { CarpentersSquareDocument.sharedInstance }

}
