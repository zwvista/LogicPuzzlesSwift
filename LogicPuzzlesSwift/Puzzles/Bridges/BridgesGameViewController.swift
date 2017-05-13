//
//  BridgesGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class BridgesGameViewController: GameViewController, GameDelegate, BridgesMixin {
    typealias GM = BridgesGameMove
    typealias GS = BridgesGameState

    var scene: BridgesGameScene {
        get {return getScene() as! BridgesGameScene}
        set {setScene(scene: newValue)}
    }
    var game: BridgesGame {
        get {return getGame() as! BridgesGame}
        set {setGame(game: newValue)}
    }
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
            let move = BridgesGameMove(pFrom: pLast!, pTo: p)
            _ = game.switchBridges(move: move)
            pLast = p; f()
        case .ended:
            pLast = nil
        default:
            break
        }
    }
    
    func updateSolutionUI() {
        let rec = gameDocument.levelProgressSolution
        let hasSolution = rec.moveIndex != 0
        lblSolution.text = "Solution: " + (!hasSolution ? "None" : "\(rec.moveIndex)")
        btnLoadSolution.isEnabled = hasSolution
        btnDeleteSolution.isEnabled = hasSolution
    }
    
    func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let layout = gameDocument.levels[gameDocument.selectedLevelID]!
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = BridgesGame(layout: layout, delegate: self)
        
        // restore game state
        for case let rec as MoveProgress in gameDocument.moveProgress {
            let move = gameDocument.loadMove(from: rec)!
            _ = game.switchBridges(move: move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        if case 0..<game.moveCount = moveIndex {
            while moveIndex != game.moveIndex {
                game.undo()
            }
        }
        scene.levelUpdated(from: game.states[0], to: game.state)
    }
    
    func moveAdded(_ game: AnyObject, move: BridgesGameMove) {
        guard !levelInitilizing else {return}
        let game = game as! BridgesGame
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func updateMovesUI(_ game: BridgesGame) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? .white : .black
        btnSaveSolution.isEnabled = game.isSolved
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
    
    override func undoGame(_ sender: Any) {
        game.undo()
    }
    
    override func redoGame(_ sender: Any) {
        game.redo()
    }
    
    override func clearGame(_ sender: Any) {
        yesNoAction(title: "Clear", message: "Do you really want to reset the level?") { (action) in
            self.gameDocument.clearGame()
            self.startGame()
        }
    }

    override func saveSolution(_ sender: Any) {
        gameDocument.saveSolution(game: game)
        updateSolutionUI()
    }
    
    override func loadSolution(_ sender: Any) {
        gameDocument.loadSolution()
        startGame()
    }
    
    override func deleteSolution(_ sender: Any) {
        yesNoAction(title: "Delete", message: "Do you really want to delete the solution?") { (action) in
            self.gameDocument.deleteSolution()
            self.updateSolutionUI()
        }
    }
}
