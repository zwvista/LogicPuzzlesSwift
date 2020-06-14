//
//  RoomsGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class RoomsGameViewController: GameGameViewController2<RoomsGameState, RoomsGame, RoomsDocument, RoomsGameScene> {
    var gameDocument: RoomsDocument { RoomsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { RoomsDocument.sharedInstance }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = RoomsGameScene(size: skView.bounds.size)
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
        let (b, p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        guard b else {return}
        var move = RoomsGameMove(p: p, dir: dir, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func newGame(level: GameLevel) -> RoomsGame {
        RoomsGame(layout: level.layout, delegate: self)
    }
}
