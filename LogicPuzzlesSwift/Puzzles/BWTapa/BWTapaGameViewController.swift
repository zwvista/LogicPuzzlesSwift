//
//  BWTapaGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BWTapaGameViewController: GameGameViewController, GameDelegate {
    typealias GM = BWTapaGameMove
    typealias GS = BWTapaGameState

    var scene: BWTapaGameScene {
        get {return getScene() as! BWTapaGameScene}
        set {setScene(scene: newValue)}
    }
    var game: BWTapaGame {
        get {return getGame() as! BWTapaGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: BWTapaDocument { return BWTapaDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return BWTapaDocument.sharedInstance }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = BWTapaGameScene(size: skView.bounds.size)
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
        var move = BWTapaGameMove(p: p, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let layout: [String] = gameDocument.levels.first(where: {$0.0 == gameDocument.selectedLevelID}).map({$0.1}) ?? gameDocument.levels.first!.1
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = BWTapaGame(layout: layout, delegate: self)
        
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
        scene.levelUpdated(from: game.states[0], to: game.state)
    }
    
    func moveAdded(_ game: AnyObject, move: BWTapaGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func levelInitilized(_ game: AnyObject, state: BWTapaGameState) {
        let game = game as! BWTapaGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: BWTapaGameState, to stateTo: BWTapaGameState) {
        let game = game as! BWTapaGame
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
