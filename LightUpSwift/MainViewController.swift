//
//  MainViewController.swift
//  LightUpSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, GameManagers {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        documentManager.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumeGame(self)
    }
    
    @IBAction func resumeGame(_ sender: AnyObject) {
        documentManager.resumeGame()
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }

}
