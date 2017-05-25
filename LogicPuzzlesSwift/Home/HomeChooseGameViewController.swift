//
//  HomeChooseGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by nttdata on 2016/11/14.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit

class HomeChooseGameViewController: UITableViewController, HomeMixin {
    
    var gameNames: [String]!
    let name2title = [
        "AbstractPainting": "Abstract Painting",
        "BattleShips": "Battle Ships",
        "BootyIsland": "Booty Island",
        "BoxItAgain": "Box It Again",
        "BoxItAround": "Box It Around",
        "BoxItUp": "Box It Up",
        "BusySeas": "Busy Seas",
        "BWTapa": "B&W Tapa",
        "DigitalBattleShips": "Digital Battle Ships",
        "FenceItUp": "Fence It Up",
        "FenceSentinels": "Fence Sentinels",
        "LightBattleShips": "Light Battle Ships",
        "LightenUp": "Lighten Up",
        "MineShips": "Mine Ships",
        "MiniLits": "Mini-Lits",
        "NumberPath": "Number Path",
        "PaintTheNurikabe": "Paint The Nurikabe",
        "ProductSentinels": "Product Sentinels",
        "TapaIslands": "Tapa Islands",
        "TapAlike": "Tap-Alike",
        "TapARow": "Tap-A-Row",
        "TapDifferently": "Tap Differently",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameNames = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            .filter({s in s[s.length - ".xml".length..<s.length] == ".xml"})
            .map({s in s[0..<s.length - ".xml".length]})
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let gameName = gameNames[indexPath.row]
        let gameTitle = name2title[gameName] ?? gameName
        cell.textLabel!.restorationIdentifier = gameName
        cell.textLabel!.text = gameTitle
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        currentGameName = cell.textLabel!.restorationIdentifier!
        currentGameTitle = cell.textLabel!.text!
        gameDocument.resumeGame(gameName: currentGameName, gameTitle: currentGameTitle)
        dismiss(animated: true, completion: {
            let vc = (UIApplication.shared.keyWindow!.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController
            vc.resumeGame(vc)
        })
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
