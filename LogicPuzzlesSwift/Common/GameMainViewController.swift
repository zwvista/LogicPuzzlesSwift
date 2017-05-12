//
//  GameMainViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/21.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GameMainViewController: UIViewController {

    @IBOutlet weak var lblGameTitle: UILabel!

    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return false}
    
    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)MainViewController").self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblGameTitle.text = currentGameTitle
        let toResume = ((UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController).toResume
        if toResume {resumGame(self)}
    }
 
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func startGame(_ sender: AnyObject) {
    }
    
    @IBAction func resumGame(_ sender: AnyObject) {
    }
    
    func resumeGame() {
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }
    
    @IBAction func backToMain(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
