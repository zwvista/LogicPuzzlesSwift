//
//  CastlePatrolGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class CastlePatrolGameViewController: GameGameViewController2<CastlePatrolGameState, CastlePatrolGame, CastlePatrolDocument, CastlePatrolGameScene> {
    override func getGameDocument() -> GameDocumentBase { CastlePatrolDocument.sharedInstance }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        var move = CastlePatrolGameMove(p: p)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> CastlePatrolGame {
        CastlePatrolGame(layout: level.layout, delegate: self)
    }
}
