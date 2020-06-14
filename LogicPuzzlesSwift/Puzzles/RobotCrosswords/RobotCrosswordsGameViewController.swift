//
//  RobotCrosswordsGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class RobotCrosswordsGameViewController: GameGameViewController {
    typealias GS = RobotCrosswordsGameState

    var scene: RobotCrosswordsGameScene {
        get { getScene() as! RobotCrosswordsGameScene }
        set { setScene(scene: newValue) }
    }
    var game: RobotCrosswordsGame {
        get { getGame() as! RobotCrosswordsGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: RobotCrosswordsDocument { RobotCrosswordsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { RobotCrosswordsDocument.sharedInstance }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = RobotCrosswordsGameScene(size: skView.bounds.size)
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
        var move = RobotCrosswordsGameMove(p: p, obj: -1)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level = gameDocument.levels.first(where: { $0.id == gameDocument.selectedLevelID }) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer { levelInitilizing = false }
        game = RobotCrosswordsGame(layout: level.layout, delegate: self)
        
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
        gameDocument.moveAdded(game: game, move: move as! RobotCrosswordsGameMove)
    }
    
    override func levelInitilized(_ game: AnyObject, state: AnyObject) {
        let game = game as! RobotCrosswordsGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state as! RobotCrosswordsGameState, skView: skView)
    }
    
    override func levelUpdated(_ game: AnyObject, from stateFrom: AnyObject, to stateTo: AnyObject) {
        let game = game as! RobotCrosswordsGame
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom as! RobotCrosswordsGameState, to: stateTo as! RobotCrosswordsGameState)
        gameDocument.levelUpdated(game: game)
    }
    
    override func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
   }
}
