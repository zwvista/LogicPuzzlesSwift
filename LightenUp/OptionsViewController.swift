//
//  OptionsViewController.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/25.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    
    var options: GameProgress { return GameDocument.sharedInstance.gameProgress }
    @IBOutlet weak var swUseMarker: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rec = options
        swUseMarker.isOn = rec.useMarker
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        let rec = options
        rec.useMarker = swUseMarker.isOn
        rec.commit()
        
        self.dismiss(animated: true, completion: nil)
    }

}
