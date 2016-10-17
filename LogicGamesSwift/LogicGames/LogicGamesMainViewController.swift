//
//  MainViewController.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class LogicGamesMainViewController: UIViewController, LogicGamesMixin {
    
    public private(set) var toResume = false
    
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
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func resumeGame(_ sender: AnyObject) {
        startGame(gameName: gameDocument.gameProgress.gameName!, toResume: true)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        startGame(gameName: (sender as! UIButton).restorationIdentifier!, toResume: false)
    }
    
    // http://www.newventuresoftware.com/blog/organizing-xcode-projects-using-multiple-storyboards
    private func startGame(gameName: String, toResume: Bool) {
        gameDocument.resumeGame(gameName: gameName)
        self.toResume = toResume
        let storyboard = UIStoryboard(name: gameName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController") as UIViewController
        self.present(controller, animated: true, completion: nil)
    }

}
