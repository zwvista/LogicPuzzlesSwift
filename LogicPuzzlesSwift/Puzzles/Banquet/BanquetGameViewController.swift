//
//  BanquetGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BanquetGameViewController: GameGameViewController2<BanquetGameState, BanquetGame, BanquetDocument, BanquetGameScene> {
    override func getGameDocument() -> GameDocumentBase { BanquetDocument.sharedInstance }
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
        var move = BanquetGameMove(p: p, dir: BanquetGame.PUZ_TAP_MOVE)
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
            guard pLast != p && pLast != nil else {break}
            defer { pLast = nil }
            guard let dir = BanquetGame.offset.firstIndex(of: p - pLast!) else {break}
            var move = BanquetGameMove(p: pLast!, dir: dir)
            if game.setObject(move: &move) { f() }
        default:
            break
        }
    }

    override func newGame(level: GameLevel) -> BanquetGame {
        BanquetGame(layout: level.layout, delegate: self)
    }
}
