//
//  GameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController<GM, GS: GameStateBase>: UIViewController, GameDelegate, GameMixin {
    
    var gameDocumentBase: GameDocument<GM>!
    var sceneBase: GameScene<GS>!
    weak var skView: SKView!
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
    
    func startGame() {}
    
    func moveAdded(_ game: AnyObject, move: GM) {
        guard !levelInitilizing else {return}
        let game = game as! BridgesGame
        gameDocumentBase.moveAdded(game: game, move: move)
    }
    
    func updateLabels(_ game: Game<GM, GS>) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? SKColor.white : SKColor.black
    }
    
    func levelInitilized(_ game: AnyObject, state: GS) {
        let game = game as! Game<GM, GS>
        updateLabels(game)
        sceneBase.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: GS, to stateTo: GS) {
        let game = game as! Game<GM, GS>
        updateLabels(game)
        sceneBase.levelUpdated(from: stateFrom, to: stateTo)
        guard !levelInitilizing else {return}
        gameDocumentBase.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: AnyObject) {
        if !levelInitilizing {
            soundManager.playSoundSolved()
        }
    }
    
    @IBAction func undoGame(_ sender: AnyObject) {
        let game = sender as! Game<GM, GS>
        game.undo()
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        let game = sender as! Game<GM, GS>
        game.redo()
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Clear", message: "Do you really want to reset the level?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.gameDocumentBase.clearGame()
            self.startGame()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
}
