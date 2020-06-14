//
//  SkyscrapersGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class SkyscrapersGameViewController: GameGameViewController2<SkyscrapersGameState, SkyscrapersGame, SkyscrapersDocument, SkyscrapersGameScene> {
    var gameDocument: SkyscrapersDocument { SkyscrapersDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { SkyscrapersDocument.sharedInstance }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = SkyscrapersGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
        
        startGame()
    }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        var move = SkyscrapersGameMove(p: p, obj: 0)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> SkyscrapersGame {
        SkyscrapersGame(layout: level.layout, delegate: self)
    }
}
