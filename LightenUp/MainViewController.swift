//
//  MainViewController.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var selectedLevelID: String!
    var gameProgress: GameProgress {
        let result = GameProgress.query().fetch()!
        return result.count == 0 ? GameProgress() : (result[0] as! GameProgress)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedLevelID = gameProgress.levelID
    }
    
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //UIApplication.shared.setStatusBarHidden(true, with: .none)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumeGame(self)
    }
    
    @IBAction func resumeGame(_ sender: AnyObject) {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
        
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameViewController.selectedLevelID = selectedLevelID
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }

}
