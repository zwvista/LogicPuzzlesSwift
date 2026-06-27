//
//  ProofOfQuiltMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class ProofOfQuiltMainViewController: GameMainViewController {
    override func getGameDocument() -> GameDocumentBase { ProofOfQuiltDocument.sharedInstance }
}

class ProofOfQuiltOptionsViewController: GameOptionsViewController {
    override func getGameDocument() -> GameDocumentBase { ProofOfQuiltDocument.sharedInstance }
}

class ProofOfQuiltHelpViewController: GameHelpViewController {
    override func getGameDocument() -> GameDocumentBase { ProofOfQuiltDocument.sharedInstance }
}
