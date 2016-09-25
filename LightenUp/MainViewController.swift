//
//  MainViewController.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var doc: GameDocument!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doc = GameDocument()
    }
    
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        doc.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumeGame(self)
    }
    
    @IBAction func resumeGame(_ sender: AnyObject) {
        doc.resumeGame()
        
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameViewController.doc = doc
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }

}
