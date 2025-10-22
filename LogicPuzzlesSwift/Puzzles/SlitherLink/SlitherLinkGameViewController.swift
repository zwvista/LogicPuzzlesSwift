//
//  SlitherLinkGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class SlitherLinkGameViewController: GameGameViewController2<SlitherLinkGameState, SlitherLinkGame, SlitherLinkDocument, SlitherLinkGameScene> {
    override func getGameDocument() -> GameDocumentBase { SlitherLinkDocument.sharedInstance }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (b, p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        guard b else {return}
        var move = SlitherLinkGameMove(p: p, dir: dir)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
   
    override func newGame(level: GameLevel) -> SlitherLinkGame {
        SlitherLinkGame(layout: level.layout, delegate: self)
    }
}
