//
//  LineSweeperGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class LineSweeperGameViewController: GameGameViewController2<LineSweeperGameState, LineSweeperGame, LineSweeperDocument, LineSweeperGameScene> {
    override func getGameDocument() -> GameDocumentBase { LineSweeperDocument.sharedInstance }
    var pLast: Position?
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        var move = LineSweeperGameMove(p: p, dir: dir)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let isH = game.isHint(p: p)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            guard !isH else {break}
            pLast = p; f()
        case .changed:
            guard !isH && pLast != nil && pLast != p else {break}
            defer { pLast = p }
            guard let dir = LineSweeperGame.offset.firstIndex(of: p - pLast!) else {break}
            var move = LineSweeperGameMove(p: p)
            if game.setObject(move: &move) { f() }
        case .ended:
            pLast = nil
        default:
            break
        }
    }

    override func newGame(level: GameLevel) -> LineSweeperGame {
        LineSweeperGame(layout: level.layout, delegate: self)
    }
}
