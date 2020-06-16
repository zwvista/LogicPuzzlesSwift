//
//  SlitherLinkHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class SlitherLinkHelpViewController: GameHelpViewController {

    var gameDocument: SlitherLinkDocument { SlitherLinkDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { SlitherLinkDocument.sharedInstance }

}
