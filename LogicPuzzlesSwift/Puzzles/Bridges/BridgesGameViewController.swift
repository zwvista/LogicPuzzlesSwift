//
//  BridgesGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BridgesGameViewController: GameGameViewController, GameDelegate {
    typealias GM = BridgesGameMove
    typealias GS = BridgesGameState

    var scene: BridgesGameScene {
        get { getScene() as! BridgesGameScene }
        set { setScene(scene: newValue) }
    }
    var game: BridgesGame {
        get { getGame() as! BridgesGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: BridgesDocument { BridgesDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { BridgesDocument.sharedInstance }
    var pLast: Position?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = BridgesGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
        
        startGame()
    }
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let isI = game.isIsland(p: p)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            guard isI else {break}
            pLast = p; f()
        case .changed:
            guard isI && pLast != nil && pLast != p else {break}
            var move = BridgesGameMove(pFrom: pLast!, pTo: p)
            _ = game.switchBridges(move: &move)
            pLast = p; f()
        case .ended:
            pLast = nil
        default:
            break
        }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level: GameLevel = gameDocument.levels.first(where: { $0.id == gameDocument.selectedLevelID }) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer { levelInitilizing = false }
        game = BridgesGame(layout: level.layout, delegate: self)
        
        // restore game state
        for case let rec as MoveProgress in gameDocument.moveProgress {
            var move = gameDocument.loadMove(from: rec)!
            _ = game.switchBridges(move: &move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        if case 0..<game.moveCount = moveIndex {
            while moveIndex != game.moveIndex {
                game.undo()
            }
        }
        scene.levelUpdated(from: game.states[0], to: game.currentState)
    }
    
    func moveAdded(_ game: AnyObject, move: BridgesGameMove) {
        guard !levelInitilizing else {return}
        let game = game as! BridgesGame
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func levelInitilized(_ game: AnyObject, state: BridgesGameState) {
        let game = game as! BridgesGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: BridgesGameState, to stateTo: BridgesGameState) {
        let game = game as! BridgesGame
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom, to: stateTo)
        gameDocument.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
    }
}
