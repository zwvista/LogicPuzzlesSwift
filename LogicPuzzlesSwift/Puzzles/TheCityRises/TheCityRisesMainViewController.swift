//
//  TheCityRisesMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class TheCityRisesMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { TheCityRisesDocument.sharedInstance }
}

class TheCityRisesOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { TheCityRisesDocument.sharedInstance }
}

class TheCityRisesHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { TheCityRisesDocument.sharedInstance }
}
