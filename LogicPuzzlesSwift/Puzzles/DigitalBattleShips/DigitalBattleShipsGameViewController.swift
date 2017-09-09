//
//  DigitalBattleShipsGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class DigitalBattleShipsGameViewController: GameGameViewController, GameDelegate {
    typealias GM = DigitalBattleShipsGameMove
    typealias GS = DigitalBattleShipsGameState

    var scene: DigitalBattleShipsGameScene {
        get {return getScene() as! DigitalBattleShipsGameScene}
        set {setScene(scene: newValue)}
    }
    var game: DigitalBattleShipsGame {
        get {return getGame() as! DigitalBattleShipsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: DigitalBattleShipsDocument { return DigitalBattleShipsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return DigitalBattleShipsDocument.sharedInstance }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = DigitalBattleShipsGameScene(size: skView.bounds.size)
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
        var move = DigitalBattleShipsGameMove(p: p, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level: GameLevel = gameDocument.levels.first(where: {$0.id == gameDocument.selectedLevelID}) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = DigitalBattleShipsGame(layout: level.layout, elemLevel: level.elemLevel, delegate: self)
        
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
    
    func moveAdded(_ game: AnyObject, move: DigitalBattleShipsGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func levelInitilized(_ game: AnyObject, state: DigitalBattleShipsGameState) {
        let game = game as! DigitalBattleShipsGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: DigitalBattleShipsGameState, to stateTo: DigitalBattleShipsGameState) {
        let game = game as! DigitalBattleShipsGame
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
