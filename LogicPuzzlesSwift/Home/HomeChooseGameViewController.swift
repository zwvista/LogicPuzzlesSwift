//
//  HomeChooseGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by nttdata on 2016/11/14.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HomeChooseGameViewController: UITableViewController, HomeMixin {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let gameName = cell.textLabel!.restorationIdentifier!
        gameDocument.resumeGame(gameName: gameName)
        dismiss(animated: true, completion: {
            let vc = (UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController
            vc.resumeGame(vc)
        })
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
