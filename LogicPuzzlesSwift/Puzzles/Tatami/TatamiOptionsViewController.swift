//
//  TatamiOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TatamiOptionsViewController: GameOptionsViewController {

    var gameDocument: TatamiDocument { return TatamiDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TatamiDocument.sharedInstance }

}
