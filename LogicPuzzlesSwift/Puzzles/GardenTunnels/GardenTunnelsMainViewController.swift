//
//  GardenTunnelsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GardenTunnelsMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { GardenTunnelsDocument.sharedInstance }
}

class GardenTunnelsOptionsViewController: GameOptionsViewController {
        override func getGameDocument() -> GameDocumentBase { GardenTunnelsDocument.sharedInstance }
}

class GardenTunnelsHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { GardenTunnelsDocument.sharedInstance }
}
