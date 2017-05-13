//
//  GameOptionsViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class GameOptionsViewController: UITableViewController {
    
    @IBOutlet weak var lblMarker: UILabel!
    @IBOutlet weak var lblMarkerOption: UILabel!
    @IBOutlet weak var swAllowedObjectsOnly: UISwitch!

    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return false}
    
    // http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
    override func awakeFromNib() {
        object_setClass(self, NSClassFromString("LogicPuzzlesSwift.\(currentGameName)OptionsViewController").self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func allowedObjectsOnlyChanged(_ sender: Any) {
    }
    
    @IBAction func onDefault(_ sender: Any) {
        let alertController = UIAlertController(title: "Default Options", message: "Do you really want to reset the options?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.onDefault()
        }
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func onDefault() {}

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
