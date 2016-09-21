//
//  GameViewController.swift
//  LightenUp
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
    var loader: GameLoader!
    var selectedLevelID: String!
    var levelProgress: LevelProgress {
        let result = LevelProgress.query().where(withFormat: "levelID = %@", withParameters: [selectedLevelID]).fetch()!
        return result.count == 0 ? LevelProgress() : (result[0] as! LevelProgress)
    }
    var levelInitilizing = false

    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var btnLevel1: UIButton!
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
        
        loader = GameLoader()
        
        lblLevel.textColor = SKColor.white
        lblMoves.textColor = SKColor.white
        
        startGame()
    }
    
    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func toggleObject(p: Position) {
        let (changed, move) = game.toggleObject(p: p)
        guard changed else {return}
        scene.process(move: move)
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        toggleObject(p: p)
    }
    
    func startGame() {
        lblLevel.text = selectedLevelID
        let layout = loader.levels[selectedLevelID]!
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = Game(layout: layout, delegate: self)
        
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width - 80) / CGFloat(game.size.col)
        scene.addGrid(to: skView, rows: game.size.row, cols: game.size.col, blockSize: blockSize)
        scene.addWalls(from: game)
        
        // restore game state
        let rec2 = levelProgress
        guard let movesAsString = rec2.movesAsString else {return}
        for p in Game.movesFrom(str: movesAsString) {
            toggleObject(p: p)
        }
        let moveIndex = Int(rec2.moveIndex!)
        guard case 0 ..< game.moveCount = moveIndex else {return}
        while moveIndex != game.moveIndex { undoGame(self) }
    }
    
    func gameUpdated(_ sender: Game) {
        lblMoves.text = "Moves: \(sender.moveIndex)(\(sender.moveCount))"
        lblSolved.textColor = sender.isSolved ? SKColor.white : SKColor.black
        
        guard !levelInitilizing else {return}
        let rec = levelProgress
        rec.levelID = selectedLevelID
        rec.movesAsString = sender.movesAsString
        rec.moveIndex = sender.moveIndex as NSNumber?
        rec.commit()
    }
    
    func gameSolved(_ sender: Game) {
    }
    
    @IBAction func undoGame(_ sender: AnyObject) {
        guard game.canUndo else {return}
        let move = game.undo()
        scene.process(move: move)
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        guard game.canRedo else {return}
        let move = game.redo()
        scene.process(move: move)
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        let rec = levelProgress
        rec.movesAsString = nil
        rec.moveIndex = 0
        rec.commit()
        startGame()
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }

}
