//
//  BalancedTapasGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BalancedTapasGameViewController: GameGameViewController2<BalancedTapasGameState, BalancedTapasGame, BalancedTapasDocument, BalancedTapasGameScene> {
    var gameDocument: BalancedTapasDocument { BalancedTapasDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { BalancedTapasDocument.sharedInstance }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = BalancedTapasGameScene(size: skView.bounds.size)
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
        var move = BalancedTapasGameMove(p: p, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> BalancedTapasGame {
        BalancedTapasGame(layout: level.layout, leftPart: level.settings["LeftPart"]!, delegate: self)
    }
}
