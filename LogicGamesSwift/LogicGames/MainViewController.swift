//
//  MainViewController.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LightUpMixin {
    
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
    
    @IBAction func resumGame(_ sender: AnyObject) {
        startGame(name: "LightUp")
    }
    
    @IBAction func startGameLightUp(_ sender: AnyObject) {
        startGame(name: "LightUp")
    }
    
    @IBAction func startGameBridges(_ sender: AnyObject) {
        startGame(name: "Bridges")
    }
    
    // http://www.newventuresoftware.com/blog/organizing-xcode-projects-using-multiple-storyboards
    private func startGame(name: String) {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController") as UIViewController
        self.present(controller, animated: true, completion: nil)
    }

}
