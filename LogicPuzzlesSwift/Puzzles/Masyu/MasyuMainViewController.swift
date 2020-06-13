//
//  MasyuMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MasyuMainViewController: GameMainViewController {

    var gameDocument: MasyuDocument { MasyuDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { MasyuDocument.sharedInstance }

}
