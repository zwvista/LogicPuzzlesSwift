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
    weak var selectedButton: UIButton!
    var levelID: String {
        return selectedButton.titleLabel!.text!;
    }
    var levelData: UserData {
        let result = UserData.query().where(withFormat: "levelID = %@", withParameters: [levelID]).fetch()!
        return result.count == 0 ? UserData() : (result[0] as! UserData)
    }
    var gameInitilizing = false

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
        loader.load()
        
        lblLevel.textColor = SKColor.white
        lblMoves.textColor = SKColor.white
        
        startGame(btnLevel1)
    }
    
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
    
    @IBAction func startGame(_ sender: AnyObject) {
        selectedButton = sender as! UIButton
        let t = levelID
        lblLevel.text = t
        let idx = t.substring(from: t.index(t.startIndex, offsetBy: String("level ")!.characters.count))
        let layout = loader.levels[idx]!
        
        gameInitilizing = true
        defer {gameInitilizing = false}
        game = Game(layout: layout, delegate: self)
        
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width - 80) / CGFloat(game.size.col)
        scene.addGrid(to: skView, rows: game.size.row, cols: game.size.col, blockSize: blockSize)
        scene.addWalls(from: game)
        
        guard let moves = levelData.moves else {return}
        for p in Game.movesFrom(str: moves) {
            toggleObject(p: p)
        }
    }
    
    func gameUpdated(_ sender: Game) {
        lblMoves.text = "Moves: \(sender.moveIndex)(\(sender.moveCount))"
        lblSolved.textColor = sender.isSolved ? SKColor.white : SKColor.black
        
        guard !gameInitilizing else {return}
        let rec = levelData
        rec.levelID = levelID
        rec.moves = sender.movesAsString
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
        let rec = levelData
        rec.moves = nil
        rec.commit()
        startGame(selectedButton)
    }

}
