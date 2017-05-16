//
//  BoxItAroundGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BoxItAroundGameViewController: GameGameViewController, GameDelegate {
    typealias GM = BoxItAroundGameMove
    typealias GS = BoxItAroundGameState

    var scene: BoxItAroundGameScene {
        get {return getScene() as! BoxItAroundGameScene}
        set {setScene(scene: newValue)}
    }
    var game: BoxItAroundGame {
        get {return getGame() as! BoxItAroundGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: BoxItAroundDocument { return BoxItAroundDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return BoxItAroundDocument.sharedInstance }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = BoxItAroundGameScene(size: skView.bounds.size)
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
        var move = BoxItAroundGameMove(p: p, dir: dir, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }

    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let layout: [String] = gameDocument.levels.first(where: {$0.0 == gameDocument.selectedLevelID}).map({$0.1}) ?? gameDocument.levels.first!.1
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = BoxItAroundGame(layout: layout, delegate: self)
        
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
    
    func moveAdded(_ game: AnyObject, move: BoxItAroundGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func levelInitilized(_ game: AnyObject, state: BoxItAroundGameState) {
        let game = game as! BoxItAroundGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: BoxItAroundGameState, to stateTo: BoxItAroundGameState) {
        let game = game as! BoxItAroundGame
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
