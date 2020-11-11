//
//  HomeDocument.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import RealmSwift

class HomeDocument {
    static var sharedInstance = HomeDocument()
    let realm = try! Realm()
    var gameProgress: HomeGameProgress {
        let result = realm.objects(HomeGameProgress.self)
        return result.count == 0 ? HomeGameProgress() : result[0]
    }
    
    func resumeGame(gameName: String, gameTitle: String) {
        try! realm.write {
            let rec = gameProgress
            rec.gameName = gameName
            rec.gameTitle = gameTitle
            realm.add(rec, update: .all)
        }
    }

}
