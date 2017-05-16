//
//  GameGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameGameViewController: UIViewController, SoundMixin {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblGameTitle: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    @IBOutlet weak var lblSolution: UILabel!
    @IBOutlet weak var btnSaveSolution: UIButton!
    @IBOutlet weak var btnLoadSolution: UIButton!
    @IBOutlet weak var btnDeleteSolution: UIButton!
    
    private var scene: SKScene?
    func getScene() -> SKScene? {return scene}
    func setScene(scene: SKScene?) {self.scene = scene}
    private var game: GridGameBase?
    func getGame() -> GridGameBase? {return game}
    func setGame(game: GridGameBase?) {self.game = game}
    private var gameDocument: GameDocumentBase! { return getGameDocument() }
    func getGameDocument() -> GameDocumentBase! { return nil }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    var allowedObjectsOnly: Bool { return gameOptions.option2?.toBool() ?? false }
    
    weak var skView: SKView!
    var levelInitilizing = false

    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return false}
    
    // http://stackoverflow.com/questions/14111572/how-to-use-single-storyboard-uiviewcontroller-for-multiple-subclass
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)GameViewController").self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as! SKView
        skView.isMultipleTouchEnabled = false

        lblGameTitle.text = currentGameTitle
    }
    
    func updateSolutionUI() {
        let rec = gameDocument.levelProgressSolution
        let hasSolution = rec.moveIndex != 0
        lblSolution.text = "Solution: " + (!hasSolution ? "None" : "\(rec.moveIndex)")
        btnLoadSolution.isEnabled = hasSolution
        btnDeleteSolution.isEnabled = hasSolution
    }
    
    func updateMovesUI(_ game: GridGameBase) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? .white : .black
        btnSaveSolution.isEnabled = game.isSolved
    }
    
    func startGame() {
    }

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
    }

    @IBAction func undoGame(_ sender: Any) {
        game?.undo()
    }
    
    @IBAction func redoGame(_ sender: Any) {
        game?.redo()
    }
    
    @IBAction func clearGame(_ sender: Any) {
        yesNoAction(title: "Clear", message: "Do you really want to reset the level?") { (action) in
            self.gameDocument.clearGame()
            self.startGame()
        }
    }
    
    @IBAction func saveSolution(_ sender: Any) {
        gameDocument.saveSolution(game: game!)
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
    
    @IBAction func backToMain(_ sender: Any) {
        navigationController!.popViewController(animated: true)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
    
    func yesNoAction(title: String?, message: String?, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: handler)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
