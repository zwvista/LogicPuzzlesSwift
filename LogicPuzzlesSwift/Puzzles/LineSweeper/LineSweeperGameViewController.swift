//
//  LineSweeperGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class LineSweeperGameViewController: GameGameViewController, GameDelegate {
    typealias GM = LineSweeperGameMove
    typealias GS = LineSweeperGameState

    var scene: LineSweeperGameScene {
        get { getScene() as! LineSweeperGameScene }
        set { setScene(scene: newValue) }
    }
    var game: LineSweeperGame {
        get { getGame() as! LineSweeperGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: LineSweeperDocument { LineSweeperDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { LineSweeperDocument.sharedInstance }
    var pLast: Position?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = LineSweeperGameScene(size: skView.bounds.size)
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
        let (p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        var move = LineSweeperGameMove(p: p, dir: dir)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let isH = game.isHint(p: p)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            guard !isH else {break}
            pLast = p; f()
        case .changed:
            guard !isH && pLast != nil && pLast != p else {break}
            defer { pLast = p }
            guard let dir = LineSweeperGame.offset.firstIndex(of: p - pLast!) else {break}
            var move = LineSweeperGameMove(p: pLast!, dir: dir / 2)
            if game.setObject(move: &move) { f() }
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
        game = LineSweeperGame(layout: level.layout, delegate: self)
        
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
    
    func moveAdded(_ game: AnyObject, move: LineSweeperGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func levelInitilized(_ game: AnyObject, state: LineSweeperGameState) {
        let game = game as! LineSweeperGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: LineSweeperGameState, to stateTo: LineSweeperGameState) {
        let game = game as! LineSweeperGame
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
