//
//  GardenerGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GardenerGameViewController: GameGameViewController2<GardenerGameState, GardenerGame, GardenerDocument, GardenerGameScene> {
    var gameDocument: GardenerDocument { GardenerDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { GardenerDocument.sharedInstance }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        var move = GardenerGameMove(p: p, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
   
    override func newGame(level: GameLevel) -> GardenerGame {
        GardenerGame(layout: level.layout, delegate: self)
    }
}
