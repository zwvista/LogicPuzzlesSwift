//
//  NumberPathGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class NumberPathGameViewController: GameGameViewController2<NumberPathGameState, NumberPathGame, NumberPathDocument, NumberPathGameScene> {
    var gameDocument: NumberPathDocument { NumberPathDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase { NumberPathDocument.sharedInstance }
    var pLast: Position?
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        var move = NumberPathGameMove(p: p, dir: dir)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func handlePan(_ sender: UIPanGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        let f = { self.soundManager.playSoundTap() }
        switch sender.state {
        case .began:
            pLast = p; f()
        case .changed:
            guard pLast != p else {break}
            defer { pLast = p }
            guard let dir = NumberPathGame.offset.firstIndex(of: p - pLast!) else {break}
            var move = NumberPathGameMove(p: pLast!, dir: dir)
            if game.setObject(move: &move) { f() }
        default:
            break
        }
    }

    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level = gameDocument.levels.first(where: { $0.id == gameDocument.selectedLevelID }) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer { levelInitilizing = false }
        game = NumberPathGame(layout: level.layout, delegate: self)
        
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
        gameDocument.moveAdded(game: game, move: move as! NumberPathGameMove)
    }
    
    override func levelInitilized(_ game: AnyObject, state: AnyObject) {
        let game = game as! NumberPathGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state as! NumberPathGameState, skView: skView)
    }
    
    override func levelUpdated(_ game: AnyObject, from stateFrom: AnyObject, to stateTo: AnyObject) {
        let game = game as! NumberPathGame
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom as! NumberPathGameState, to: stateTo as! NumberPathGameState)
        gameDocument.levelUpdated(game: game)
    }
    
    override func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
   }
}
