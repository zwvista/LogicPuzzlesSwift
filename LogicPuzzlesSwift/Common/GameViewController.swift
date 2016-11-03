//
//  GameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController<GM, GS: GameStateBase>: UIViewController, GameDelegate {
    
    var levelInitilizing = false
    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    
    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func moveAdded(_ game: AnyObject, move: GM) {
        guard !levelInitilizing else {return}
        let game = game as! BridgesGame
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func updateLabels(_ game: CellsGame<GM, GS>) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? SKColor.white : SKColor.black
    }
    
    func levelInitilized(_ game: AnyObject, state: GS) {
        let game = game as! CellsGame<GM, GS>
        updateLabels(game)
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        scene.addGrid(to: skView, rows: game.rows, cols: game.cols, blockSize: blockSize)
        scene.addIslands(from: state)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: GS, to stateTo: GS) {
        let game = game as! CellsGame<GM, GS>
        updateLabels(game)
        scene.process(from: stateFrom, to: stateTo)
        guard !levelInitilizing else {return}
        gameDocument.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: AnyObject) {
        if !levelInitilizing {
            soundManager.playSoundSolved()
        }
    }
    
    @IBAction func undoGame(_ sender: AnyObject) {
        game.undo()
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        game.redo()
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Clear", message: "Do you really want to reset the level?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.gameDocument.clearGame()
            self.startGame()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
}
