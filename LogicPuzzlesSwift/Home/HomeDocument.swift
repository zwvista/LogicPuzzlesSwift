//
//  HomeDocument.swift
//  HomeSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class HomeDocument {
    static var sharedInstance = HomeDocument()
    var gameProgress: HomeGameProgress {
        let result = HomeGameProgress.query().fetch()!
        return result.count == 0 ? HomeGameProgress() : (result[0] as! HomeGameProgress)
    }
    
    func resumeGame(gameName: String) {
        let rec = gameProgress
        rec.gameName = gameName
        rec.commit()
    }

}
