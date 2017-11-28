//
//  DisconnectFourOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class DisconnectFourOptionsViewController: GameOptionsViewController {

    var gameDocument: DisconnectFourDocument { return DisconnectFourDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return DisconnectFourDocument.sharedInstance }

}
