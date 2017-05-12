//
//  SkyscrapersMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class SkyscrapersMainViewController: GameMainViewController, SkyscrapersMixin {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let toResume = ((UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController).toResume
        if toResume {resumGame(self)}
    }
    
    override func startGame(_ sender: AnyObject) {
        gameDocument.selectedLevelID = (sender as! UIButton).titleLabel!.text!
        resumGame(self)
    }
    
    override func resumGame(_ sender: AnyObject) {
        gameDocument.resumeGame()
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "SkyscrapersGameViewController") as! SkyscrapersGameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }
    
    override func backToMain(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
