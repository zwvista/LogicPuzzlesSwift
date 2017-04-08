//
//  LineSweeperGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class LineSweeperGameViewController: GameViewController, GameDelegate, LineSweeperMixin {

    var scene: LineSweeperGameScene!
    var game: LineSweeperGame!
    weak var skView: SKView!
    var levelInitilizing = false
    var pLast: Position?

    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    @IBOutlet weak var lblSolution: UILabel!
    @IBOutlet weak var btnSaveSolution: UIButton!
    @IBOutlet weak var btnLoadSolution: UIButton!
    @IBOutlet weak var btnDeleteSolution: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = LineSweeperGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
        
        lblLevel.textColor = .white
        lblMoves.textColor = .white
        lblSolution.textColor = .white
        
        startGame()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (p, dir) = scene.gridNode.linePosition(point: touchLocationInGrid)
        var move = LineSweeperGameMove(p: p, dir: dir)
        if game.setObject(move: &move) { soundManager.playSoundTap() }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
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
            defer {pLast = p}
            guard let dir = LineSweeperGame.offset.index(of: p - pLast!) else {break}
            var move = LineSweeperGameMove(p: pLast!, dir: dir / 2)
            if game.setObject(move: &move) {f()}
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
        game = LineSweeperGame(layout: layout, delegate: self)
        
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
    
    func moveAdded(_ game: AnyObject, move: LineSweeperGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func updateMovesUI(_ game: LineSweeperGame) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? .white : .black
        btnSaveSolution.isEnabled = game.isSolved
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
    
    @IBAction func undoGame(_ sender: AnyObject) {
        game.undo()
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        game.redo()
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        yesNoAction(title: "Clear", message: "Do you really want to reset the level?") { (action) in
            self.gameDocument.clearGame()
            self.startGame()
        }
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

    @IBAction func saveSolution(_ sender: Any) {
        gameDocument.saveSolution(game: game)
        updateSolutionUI()
    }
    
    @IBAction func loadSolution(_ sender: Any) {
        gameDocument.loadSolution()
        startGame()
    }
    
    @IBAction func deleteSolution(_ sender: Any) {
        yesNoAction(title: "Delete", message: "Do you really want to delete the solution?") { (action) in
            self.gameDocument.deleteSolution()
            self.updateSolutionUI()
        }
    }
}
