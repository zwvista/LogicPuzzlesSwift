//
//  MainViewController.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HomeMainViewController: UIViewController, HomeMixin {
    
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
        let gameName = gameDocument.gameProgress.gameName!
        toResume = true
        // http://www.newventuresoftware.com/blog/organizing-xcode-projects-using-multiple-storyboards
        let storyboard = UIStoryboard(name: gameName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "InitialController")
        self.present(controller, animated: true, completion: nil)
    }

}
