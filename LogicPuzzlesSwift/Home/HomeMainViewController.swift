//
//  GameMainViewController.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HomeMainViewController: UIViewController, HomeMixin {
    
    @IBOutlet weak var btnResumeGame: UIButton!
    
    public private(set) var toResume = false
    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return false}

    override func viewDidLoad() {
        super.viewDidLoad()        
        for subView in view.subviews {
            guard let button = subView as? UIButton, button.titleColor(for: .normal) == .white else {continue}
            button.initColors()
        }
    }
    
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        currentGameName = gameDocument.gameProgress.gameName!
        currentGameTitle = gameDocument.gameProgress.gameTitle!
        btnResumeGame.setTitle("Resume Game " + currentGameTitle, for: .normal)
    }
    
    @IBAction func resumeGame(_ sender: Any) {
        toResume = true
        // http://www.newventuresoftware.com/blog/organizing-xcode-projects-using-multiple-storyboards
        let storyboard = UIStoryboard(name: "Game", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController")
        self.present(controller, animated: true, completion: nil)
    }

}
