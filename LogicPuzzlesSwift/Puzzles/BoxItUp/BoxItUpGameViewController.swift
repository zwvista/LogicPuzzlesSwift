//
//  BoxItUpGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BoxItUpGameViewController: GameGameViewController {
    typealias GS = BoxItUpGameState

    var scene: BoxItUpGameScene {
        get { getScene() as! BoxItUpGameScene }
        set { setScene(scene: newValue) }
    }
    var game: BoxItUpGame {
        get { getGame() as! BoxItUpGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: BoxItUpDocument { BoxItUpDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { BoxItUpDocument.sharedInstance }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = BoxItUpGameScene(size: skView.bounds.size)
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
        var move = BoxItUpGameMove(p: p, dir: dir, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level = gameDocument.levels.first(where: { $0.id == gameDocument.selectedLevelID }) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer { levelInitilizing = false }
        game = BoxItUpGame(layout: level.layout, delegate: self)
        
        // restore game state
        for case let rec as MoveProgress in gameDocument.moveProgress {
            var move = gameDocument.loadMove(from: rec)!
            _ = game.setObject(move: &move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        if case 0..<game.moveCount = moveIndex {
            while moveIndex != game.moveIndex {
                game.undo()
            }
        }
        scene.levelUpdated(from: game.states[0], to: game.currentState)
    }
    
    override func moveAdded(_ game: AnyObject, move: Any) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move as! BoxItUpGameMove)
    }
    
    override func levelInitilized(_ game: AnyObject, state: AnyObject) {
        let game = game as! BoxItUpGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state as! BoxItUpGameState, skView: skView)
    }
    
    override func levelUpdated(_ game: AnyObject, from stateFrom: AnyObject, to stateTo: AnyObject) {
        let game = game as! BoxItUpGame
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom as! BoxItUpGameState, to: stateTo as! BoxItUpGameState)
        gameDocument.levelUpdated(game: game)
    }
    
    override func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
    }
}
