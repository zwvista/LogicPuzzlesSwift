//
//  Square100GameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class Square100GameViewController: GameGameViewController2<Square100GameState, Square100Game, Square100Document, Square100GameScene> {
    var gameDocument: Square100Document { Square100Document.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { Square100Document.sharedInstance }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (p, b) = scene.gridNode.tapPosition(point: touchLocationInGrid)
        var move = Square100GameMove(p: p, isRightPart: b, obj: "   ")
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> Square100Game {
        Square100Game(layout: level.layout, delegate: self)
    }
}
