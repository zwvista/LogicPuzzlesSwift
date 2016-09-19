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
    var skView: SKView!
    var loader: GameLoader!
    weak var selectedButton: UIButton!

    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var btnLevel1: UIButton!
    
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
        
        startGame(btnLevel1)
    }
    
    override var prefersStatusBarHidden : Bool {
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
        let instruction = game.toggleObject(p: p)
        scene.process(instruction: instruction)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        lblSolved.textColor = SKColor.black
        
        selectedButton = sender as! UIButton
        let t = selectedButton.titleLabel!.text!
        lblLevel.text = t
        let idx = t.substring(from: t.index(t.startIndex, offsetBy: String("level ")!.characters.count))
        game = Game(strs: loader.levels[idx]!)
        game.delegate = self
        scene.removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width - 80) / CGFloat(game.size.col)
        scene.addGrid(to: skView, rows: game.size.row, cols: game.size.col, blockSize: blockSize)
        scene.addWalls(from: game)
    }
    
    func gameSolved(_ sender: Game) {
        lblSolved.textColor = SKColor.white
    }
    
    @IBAction func undoGame(_ sender: AnyObject) {
        guard game.canUndo else {return}
        let instruction = game.undo()
        scene.process(instruction: instruction)
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
        guard game.canRedo else {return}
        let instruction = game.redo()
        scene.process(instruction: instruction)
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
        startGame(selectedButton)
    }

}
