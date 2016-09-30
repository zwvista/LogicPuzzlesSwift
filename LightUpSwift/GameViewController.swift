//
//  GameViewController.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameDelegate {

    var scene: GameScene!
    var game: Game!
    weak var skView: SKView!
    var doc: GameDocument { return GameDocument.sharedInstance }
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
        scene = GameScene(size: skView.bounds.size)
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
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        game.switchObject(p: p)
    }
    
    func startGame() {
        lblLevel.text = doc.selectedLevelID
        let layout = doc.levels[doc.selectedLevelID]!
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = Game(layout: layout, delegate: self)
        
        // restore game state
        for case let rec as MoveProgress in doc.moveProgress {
            game.setObject(p: Position(rec.row, rec.col), objType: GameObjectType.fromString(str: rec.objTypeAsString!))
        }
        let moveIndex = doc.levelProgress.moveIndex
        guard case 0 ..< game.moveCount = moveIndex else {return}
        while moveIndex != game.moveIndex {
            game.undo()
        }
    }
    
    func moveAdded(_ game: Game, move: GameMove) {
        guard !levelInitilizing else {return}
        doc.moveAdded(game: game, move: move)
    }
    
    func updateLabels(_ game: Game) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? SKColor.white : SKColor.black
    }
    
    func levelInitilized(_ game: Game, state: GameState) {
        updateLabels(game)
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width - 80) / CGFloat(game.size.col)
        scene.addGrid(to: skView, rows: game.size.row, cols: game.size.col, blockSize: blockSize)
        scene.addWalls(from: state)
    }
    
    func levelUpdated(_ game: Game, from stateFrom: GameState, to stateTo: GameState) {
        updateLabels(game)
        scene.process(from: stateFrom, to: stateTo)
        guard !levelInitilizing else {return}
        doc.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: Game) {
    }
    
    @IBAction func undoGame(_ sender: AnyObject) {
        game.undo()
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        game.redo()
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        doc.clearGame()
        startGame()
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

}
