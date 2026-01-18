//
//  PathOnTheMountainsGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class PathOnTheMountainsGameViewController: GameGameViewController2<PathOnTheMountainsGameState, PathOnTheMountainsGame, PathOnTheMountainsDocument, PathOnTheMountainsGameScene> {
    override func getGameDocument() -> GameDocumentBase { PathOnTheMountainsDocument.sharedInstance }
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
        let (p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        var move = PathOnTheMountainsGameMove(p: p, dir: dir)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            pLast = p; f()
        case .changed:
            guard pLast != p else {break}
            defer { pLast = p }
            guard let dir = PathOnTheMountainsGame.offset.firstIndex(of: p - pLast!) else {break}
            var move = PathOnTheMountainsGameMove(p: p)
            if game.setObject(move: &move) { f() }
        default:
            break
        }
    }

    override func newGame(level: GameLevel) -> PathOnTheMountainsGame {
        PathOnTheMountainsGame(layout: level.layout, delegate: self)
    }
}
