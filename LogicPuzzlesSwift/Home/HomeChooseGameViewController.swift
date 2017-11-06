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
        "BalancedTapas": "Balanced Tapas",
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
        "NoughtsAndCrosses": "Noughts & Crosses",
        "NumberPath": "Number Path",
        "OverUnder": "Over Under",
        "PaintTheNurikabe": "Paint The Nurikabe",
        "ProductSentinels": "Product Sentinels",
        "RobotCrosswords": "Robot Crosswords",
        "RobotFences": "Robot Fences",
        "Square100": "Square 100",
        "TapaIslands": "Tapa Islands",
        "TapAlike": "Tap-Alike",
        "TapARow": "Tap-A-Row",
        "TapDifferently": "Tap Differently",
        "TennerGrid": "Tenner Grid",
        "TheOddBrick": "The Odd Brick",
    ]
    var selectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameNames = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            .filter({s in s[s.length - ".xml".length..<s.length] == ".xml"})
            .map({s in s[0..<s.length - ".xml".length]})
        
        selectedRow = gameNames.index(of: gameDocument.gameProgress.gameName!)!
        let indexPath = IndexPath(row: selectedRow, section: 0)
        // https://stackoverflow.com/questions/2685548/uitableview-scrolling-to-specific-position
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        var point = tableView.contentOffset
        point.y += (navBar!.frame.height + tableView.rowHeight) / 2
        tableView.contentOffset = point
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
        cell.textLabel!.backgroundColor = indexPath.row == selectedRow ? .yellow : .white
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
