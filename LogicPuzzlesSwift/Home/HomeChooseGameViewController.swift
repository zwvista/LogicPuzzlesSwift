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
        "ABCPath": "ABC Path",
        "BWTapa": "B&W Tapa",
        "CarpentersSquare": "Carpenter's Square",
        "CarpentersWall": "Carpenter's Wall",
        "FenceLits": "FenceLits",
        "FourMeNot": "Four-Me-Not",
        "JoinMe": "Join Me!",
        "LakesAndMeadows": "Lakes and Meadows",
        "LineSweeper": "LineSweeper",
        "LoopAndBlocks": "Loop and Blocks",
        "MakeTheDifference": "Make the Difference",
        "MineSlither": "MineSlither",
        "MiniLits": "Mini-Lits",
        "NumberLink": "NumberLink",
        "NoughtsAndCrosses": "Noughts & Crosses",
        "PathOnTheHills": "Path on the Hills",
        "PathOnTheMountains": "Path on the Mountains",
        "PleaseComeBack": "Please come back",
        "PlugItIn": "Plug it in",
        "PondCamping": "Pond camping",
        "RunInALoop": "Run in a Loop",
        "SheepAndWolves": "Sheep & Wolves",
        "SlitherCorner": "SlitherCorner",
        "SlitherLink": "SlitherLink",
        "Square100": "Square 100",
        "StraightAndBendLands": "Straight and Bend Lands",
        "StraightAndTurn": "Straight and Turn",
        "TapAlike": "Tap-Alike",
        "TapARow": "Tap-A-Row",
        "TurnMeUp": "Turn me up",
        "YouTurnMeOn": "You Turn me on",
    ]
    var selectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // https://stackoverflow.com/questions/39887738/remove-suffix-from-filename-in-swift
        // https://stackoverflow.com/questions/32418917/sorting-a-string-array-and-ignoring-case
        gameNames = try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            .filter { $0.hasSuffix(".xml") }
            .map { ($0 as NSString).deletingPathExtension }
            .sorted { $0.localizedCompare($1) == .orderedAscending }
        
        selectedRow = gameNames.firstIndex(of: gameDocument.gameProgress.gameName!)!
        let indexPath = IndexPath(row: selectedRow, section: 0)
        // https://stackoverflow.com/questions/2685548/uitableview-scrolling-to-specific-position
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        var point = tableView.contentOffset
        let offset = (navBar!.frame.height + tableView.rowHeight) / 2 + navBar!.frame.height
        if point.y >= offset { point.y += offset }
        tableView.contentOffset = point
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        gameNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        let gameName = gameNames[indexPath.row]
        let gameTitle = name2title[gameName] ?? splitAndJoinWords(input: gameName)
        cell.textLabel!.restorationIdentifier = gameName
        cell.textLabel!.text = gameTitle
        cell.textLabel!.backgroundColor = indexPath.row == selectedRow ? .yellow : .white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        currentGameName = cell.textLabel!.restorationIdentifier!
        currentGameTitle = cell.textLabel!.text!
        gameDocument.resumeGame(gameName: currentGameName, gameTitle: currentGameTitle)
        dismiss(animated: true, completion: {
            // https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }!
            let vc = (keyWindow.rootViewController! as! UINavigationController).topViewController as! HomeMainViewController
            vc.updateGameTitle()
            vc.resumeGame(vc)
        })
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func splitAndJoinWords(input: String) -> String {
        let pattern = /([a-z])([A-Z])/
        let result = input.replacing(pattern) { m in
            "\(m.1) \(m.2)"
        }
        return result
    }

    // Cannot parse regular expression: lookbehind is not currently supported
//    func splitAndJoinWords2(input: String) -> String {
//        let pattern = /(?<=[a-z])(?=[A-Z])/
//        let result = input.replacing(pattern, with: " ")
//        return result
//    }

    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
