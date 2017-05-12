//
//  GameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var lblSolved: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblMoves: UILabel!
    @IBOutlet weak var lblSolution: UILabel!
    @IBOutlet weak var btnSaveSolution: UIButton!
    @IBOutlet weak var btnLoadSolution: UIButton!
    @IBOutlet weak var btnDeleteSolution: UIButton!
    
    weak var skView: SKView!
    var levelInitilizing = false

    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return false}
    
    // http://stackoverflow.com/questions/14111572/how-to-use-single-storyboard-uiviewcontroller-for-multiple-subclass
    override func viewDidLoad() {
        object_setClass(self, NSClassFromString(currentGameName).self)
        viewDidLoad()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
    }

    @IBAction func undoGame(_ sender: AnyObject) {
    }
    
    @IBAction func redoGame(_ sender: AnyObject) {
    }
    
    @IBAction func clearGame(_ sender: AnyObject) {
    }
    
    @IBAction func saveSolution(_ sender: Any) {
    }
    
    @IBAction func loadSolution(_ sender: Any) {
    }
    
    @IBAction func deleteSolution(_ sender: Any) {
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
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
