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

    @IBOutlet weak var lblSolved: UILabel!
    
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
        
        startGame(self)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
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
        
        game = Game()
        game.delegate = self
        scene.removeAllChildren()
        scene.addGrid(to: skView)
        scene.addWalls(game: game)
    }
    
    func gameSolved(_ sender: Game) {
        lblSolved.textColor = SKColor.white
    }

}
