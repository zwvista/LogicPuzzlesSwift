//
//  BridgesGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BridgesGameViewController: GameGameViewController2<BridgesGameState, BridgesGame, BridgesDocument, BridgesGameScene> {
    override func getGameDocument() -> GameDocumentBase { BridgesDocument.sharedInstance }
    var pLast: Position?
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let isI = game.isIsland(p: p)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            guard isI else {break}
            pLast = p; f()
        case .changed:
            guard isI && pLast != nil && pLast != p else {break}
            var move = BridgesGameMove(pFrom: pLast!, pTo: p)
            _ = game.switchBridges(move: &move)
            pLast = p; f()
        case .ended:
            pLast = nil
        default:
            break
        }
    }
    
    override func newGame(level: GameLevel) -> BridgesGame {
        BridgesGame(layout: level.layout, delegate: self)
    }
}
