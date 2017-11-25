//
//  RippleEffectOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class RippleEffectOptionsViewController: GameOptionsViewController {

    var gameDocument: RippleEffectDocument { return RippleEffectDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return RippleEffectDocument.sharedInstance }

}
