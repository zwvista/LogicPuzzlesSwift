//
//  TierraDelFuegoOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TierraDelFuegoOptionsViewController: GameOptionsViewController {

    var gameDocument: TierraDelFuegoDocument { TierraDelFuegoDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { TierraDelFuegoDocument.sharedInstance }

}
