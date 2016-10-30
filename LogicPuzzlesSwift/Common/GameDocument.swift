//
//  GameDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class GameDocument<G, GM> {
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!

    init(forResource name: String?) {
        let path = Bundle.main.path(forResource: name, ofType: "xml")!
        let xml = try! String(contentsOfFile: path)
        let doc = try! XMLDocument(string: xml)
        for elem in doc.root!.children {
            guard let key = elem.attr("id") else {continue}
            var arr = elem.stringValue.components(separatedBy: "\n")
            arr = Array(arr[2 ..< (arr.count - 2)])
            arr = arr.map { s in s.substring(to: s.index(before: s.endIndex)) }
            levels["Level " + key] = arr
        }
    }
    
    func levelUpdated(game: G) {}
    
    func moveAdded(game: G, move: GM) {}
    
    func resumeGame() {}
    
    func clearGame() {}
}
