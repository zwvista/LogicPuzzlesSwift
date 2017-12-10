//
//  CarpentersWallMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CarpentersWallMainViewController: GameMainViewController {

    var gameDocument: CarpentersWallDocument { return CarpentersWallDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return CarpentersWallDocument.sharedInstance }

}
