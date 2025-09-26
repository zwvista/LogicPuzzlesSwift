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
    @IBOutlet weak var btnResumeLevel: UIButton!
    @IBOutlet weak var btnPrevPage: UIButton!
    @IBOutlet weak var btnNextPage: UIButton!
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var shouldAutorotate: Bool { false }

    private var gameDocument: GameDocumentBase { getGameDocument() }
    func getGameDocument() -> GameDocumentBase! { nil }
    var gameOptions: GameProgress { gameDocument.gameProgress }
    var markerOption: Int { gameOptions.option1?.toInt() ?? 0 }
    var allowedObjectsOnly: Bool { gameOptions.option2?.toBool() ?? false }
    
    var currentPage = 0
    let countPerPage = 36
    var numPages = 1

    // http://stackoverflow.com/questions/14111572/how-to-use-single-storyboard-uiviewcontroller-for-multiple-subclass
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)MainViewController").self!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func initColors(subView: UIView) {
            guard let button = subView as? UIButton, button.titleColor(for: .normal) == .white else {return}
            button.initColors()
        }
        
        for subView in view.subviews {
            initColors(subView: subView)
            for subView2 in subView.subviews {
                initColors(subView: subView2)
            }
        }
        
        lblGameTitle.text = currentGameTitle
        numPages = (gameDocument.levels.count + countPerPage - 1) / countPerPage
        let index = gameDocument.levels.firstIndex(where: { $0.id == gameDocument.selectedLevelID }) ?? 0
        currentPage = index / countPerPage
        if numPages == 1 {
            btnPrevPage.isHidden = true
            btnNextPage.isHidden = true
        }
        showCurrentPage()
        let toResume = ((UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController).toResume
        if toResume { resumGame(self) }
    }
 
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        btnResumeLevel.setTitle("Resume Level " + gameDocument.selectedLevelID, for: .normal)
    }
    
    private func showCurrentPage() {
        for i in 0..<countPerPage {
            let button = view.viewWithTag(i + 1) as! UIButton
            let index = currentPage * countPerPage + i
            let b = index < gameDocument.levels.count
            button.isHidden = !b
            if b { button.setTitle(gameDocument.levels[index].id, for: .normal) }
        }
    }
    
    @IBAction func prevPage(_ sender: UIButton) {
        currentPage = (currentPage - 1 + numPages) % numPages
        showCurrentPage()
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        currentPage = (currentPage + 1) % numPages
        showCurrentPage()
    }
    
    @IBAction func startGame(_ sender: UIButton) {
        gameDocument.selectedLevelID = sender.titleLabel!.text!
        resumGame(self)
    }
    
    @IBAction func resumGame(_ sender: Any) {
        gameDocument.resumeGame()
        let gameViewController = self.storyboard!.instantiateViewController(withIdentifier: "GameGameViewController") as! GameGameViewController
        self.navigationController!.pushViewController(gameViewController, animated: true)
    }
    
    @IBAction func resetAllLevels(_ sender: Any) {
        yesNoAction(title: "Clear", message: "Do you really want to reset all levels in the game?") { (action) in
            self.gameDocument.resetAllLevels()
        }
    }
  
    @IBAction func backToMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
