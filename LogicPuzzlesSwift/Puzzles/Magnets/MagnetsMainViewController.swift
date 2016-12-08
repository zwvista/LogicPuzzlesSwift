//
//  MagnetsMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class MagnetsMainViewController: MainViewController, MagnetsMixin {

    override func viewDidLoad() {
        super.viewDidLoad()
        let toResume = ((UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController).toResume
        if toResume {resumGame(self)}
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
        gameDocument.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumGame(self)
    }
    
    @IBAction func resumGame(_ sender: AnyObject) {
        gameDocument.resumeGame()
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "MagnetsGameViewController") as! MagnetsGameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
