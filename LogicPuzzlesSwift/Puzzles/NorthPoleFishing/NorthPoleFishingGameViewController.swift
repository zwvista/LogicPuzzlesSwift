//
//  NorthPoleFishingGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class NorthPoleFishingGameViewController: GameGameViewController2<NorthPoleFishingGameState, NorthPoleFishingGame, NorthPoleFishingDocument, NorthPoleFishingGameScene> {
    override func getGameDocument() -> GameDocumentBase { NorthPoleFishingDocument.sharedInstance }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (b, p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        guard b else {return}
        var move = NorthPoleFishingGameMove(p: p, dir: dir, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> NorthPoleFishingGame {
        NorthPoleFishingGame(layout: level.layout, delegate: self)
    }
}
