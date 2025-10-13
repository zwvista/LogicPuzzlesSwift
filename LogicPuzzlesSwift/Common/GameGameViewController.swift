//
//  GameGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameGameViewController: UIViewController, SoundMixin, GameDelegate {
    
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblGameTitle: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    @IBOutlet weak var lblSolution: UILabel!
    @IBOutlet weak var btnSaveSolution: UIButton!
    @IBOutlet weak var btnLoadSolution: UIButton!
    @IBOutlet weak var btnDeleteSolution: UIButton!
    
    private var scene: SKScene!
    func getScene() -> SKScene { scene }
    func setScene(scene: SKScene) { self.scene = scene }
    private var game: GridGameBase!
    func getGame() -> GridGameBase { game }
    func setGame(game: GridGameBase) { self.game = game }
    private var gameDocument: GameDocumentBase { getGameDocument() }
    func getGameDocument() -> GameDocumentBase! { nil }
    var gameOptions: GameProgress { gameDocument.gameProgress }
    var markerOption: Int { gameOptions.option1?.toInt() ?? 0 }
    var allowedObjectsOnly: Bool { gameOptions.option2?.toBool() ?? false }
    
    weak var skView: SKView!
    var levelInitilizing = false

    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden: Bool { true }
    
    override var shouldAutorotate: Bool { false }
    
    // http://stackoverflow.com/questions/14111572/how-to-use-single-storyboard-uiviewcontroller-for-multiple-subclass
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)GameViewController").self!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = view as? SKView
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
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
    }

    @IBAction func undoGame(_ sender: Any) {
        game.undo()
    }
    
    @IBAction func redoGame(_ sender: Any) {
        game.redo()
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

    func startGame() {}
    func moveAdded(_ game: AnyObject, move: Any) {}
    func levelInitialized(_ game: AnyObject, state: AnyObject) {}
    func levelUpdated(_ game: AnyObject, from stateFrom: AnyObject, to stateTo: AnyObject) {}
    func gameSolved(_ game: AnyObject) {}
    func stateChanged(_ game: AnyObject, from stateFrom: AnyObject?, to stateTo: AnyObject) {}

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

class GameGameViewController2<GS: GameStateBase, G: GridGame<GS>, GD: GameDocument<GS.GM>, GSC: GameScene<GS>>: GameGameViewController {
    typealias GM = GS.GM
    
    var scene: GSC {
        get { getScene() as! GSC }
        set { setScene(scene: newValue) }
    }
    var game: G {
        get { getGame() as! G }
        set { setGame(game: newValue) }
    }
    private var gameDocument: GD! { getGameDocument() as? GD }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = GSC(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
        
        startGame()
    }

    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let level = gameDocument.levels.first(where: { $0.id == gameDocument.selectedLevelID }) ?? gameDocument.levels.first!
        
        levelInitilizing = true
        defer { levelInitilizing = false }
        game = newGame(level: level)
        
        // restore game state
        for case let rec in gameDocument.moveProgress {
            var move = gameDocument.loadMove(from: rec)!
            _ = game.setObject(move: &move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        if case 0..<game.moveCount = moveIndex {
            while moveIndex != game.moveIndex {
                game.undo()
            }
        }
        scene.levelUpdated(from: game.states[0], to: game.currentState)
        scene.stateChanged(from: game.states[0], to: game.currentState)
    }
    
    override func moveAdded(_ game: AnyObject, move: Any) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move as! GM)
    }
    
    override func levelInitialized(_ game: AnyObject, state: AnyObject) {
        let game = game as! G
        updateMovesUI(game)
        scene.levelInitialized(game, state: state as! GS, skView: skView)
        scene.stateChanged(from: nil, to: state as! GS)
    }
    
    override func levelUpdated(_ game: AnyObject, from stateFrom: AnyObject, to stateTo: AnyObject) {
        let game = game as! G
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom as! GS, to: stateTo as! GS)
        scene.stateChanged(from: stateFrom as? GS, to: stateTo as! GS)
        gameDocument.levelUpdated(game: game)
    }
    
    override func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
    }

    override func stateChanged(_ game: AnyObject, from stateFrom: AnyObject?, to stateTo: AnyObject) {
        scene.stateChanged(from: stateFrom as? GS, to: stateTo as! GS)
    }

    func newGame(level: GameLevel) -> G! { nil }
}
