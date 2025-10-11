//
//  HiddenPathGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class HiddenPathGameViewController: GameGameViewController2<HiddenPathGameState, HiddenPathGame, HiddenPathDocument, HiddenPathGameScene> {
    override func getGameDocument() -> GameDocumentBase { HiddenPathDocument.sharedInstance }
    var pLast: Position?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        var move = HiddenPathGameMove(p: p, obj: 0)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }

    override func newGame(level: GameLevel) -> HiddenPathGame {
        HiddenPathGame(layout: level.layout, delegate: self)
    }
}
