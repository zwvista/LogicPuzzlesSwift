//
//  SlitherLinkGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class SlitherLinkGameViewController: UIViewController, SlitherLinkGameDelegate, SlitherLinkMixin {

    var scene: SlitherLinkGameScene!
    var game: SlitherLinkGame!
    weak var skView: SKView!
    var levelInitilizing = false

    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = SlitherLinkGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
        
        lblLevel.textColor = SKColor.white
        lblMoves.textColor = SKColor.white
        
        startGame()
    }
    
    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let (b, p, orientation) = scene.gridNode.linePosition(point: touchLocationInGrid)
        guard b else {return}
        var move = SlitherLinkGameMove(p: p, objOrientation: orientation, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        let layout = gameDocument.levels[gameDocument.selectedLevelID]!
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = SlitherLinkGame(layout: layout, delegate: self)
        
        // restore game state
        for case let rec as SlitherLinkMoveProgress in gameDocument.moveProgress {
            var move = SlitherLinkGameMove(p: Position(rec.row, rec.col), objOrientation: SlitherLinkObjectOrientation(rawValue: rec.objOrientation)!, obj: SlitherLinkObject(rawValue: rec.obj)!)
                _ = game.setObject(move: &move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        guard case 0 ..< game.moveCount = moveIndex else {return}
        while moveIndex != game.moveIndex {
            game.undo()
        }
    }
    
    func moveAdded(_ game: SlitherLinkGame, move: SlitherLinkGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func updateLabels(_ game: SlitherLinkGame) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? SKColor.white : SKColor.black
    }
    
    func levelInitilized(_ game: SlitherLinkGame, state: SlitherLinkGameState) {
        updateLabels(game)
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        scene.addGrid(to: skView, rows: game.rows, cols: game.cols, blockSize: blockSize)
        scene.addHints(from: state)
    }
    
    func levelUpdated(_ game: SlitherLinkGame, from stateFrom: SlitherLinkGameState, to stateTo: SlitherLinkGameState) {
        updateLabels(game)
        scene.levelUpdated(from: stateFrom, to: stateTo)
        guard !levelInitilizing else {return}
        gameDocument.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: SlitherLinkGame) {
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
