//
//  FlowerbedShrubsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class FlowerbedShrubsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerbedShrubsDocument.sharedInstance }
}

class FlowerbedShrubsOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerbedShrubsDocument.sharedInstance }
}

class FlowerbedShrubsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { FlowerbedShrubsDocument.sharedInstance }
}
