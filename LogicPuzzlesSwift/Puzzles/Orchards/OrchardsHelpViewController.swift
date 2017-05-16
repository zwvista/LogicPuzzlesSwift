//
//  OrchardsHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class OrchardsHelpViewController: GameHelpViewController {

    var gameDocument: OrchardsDocument { return OrchardsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return OrchardsDocument.sharedInstance }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameDocument.help.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! SelfSizingTableViewCell
        cell.label.text = gameDocument.help[indexPath.row]
        return cell;
    }
}
