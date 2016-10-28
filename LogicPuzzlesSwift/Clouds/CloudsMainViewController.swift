//
//  CloudsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class CloudsMainViewController: UIViewController, CloudsMixin {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let toResume = ((UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! LogicPuzzlesMainViewController).toResume
        if toResume {resumGame(self)}
    }
    
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        gameDocument.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumGame(self)
    }
    
    @IBAction func resumGame(_ sender: AnyObject) {
        gameDocument.resumeGame()
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "CloudsGameViewController") as! CloudsGameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
