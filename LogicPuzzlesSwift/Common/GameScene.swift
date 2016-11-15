//
//  GameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene<GS: GameStateBase>: SKScene {
    func levelInitialized(_ game: AnyObject, state: GS, skView: SKView) {}
    func levelUpdated(from stateFrom: GS, to stateTo: GS) {}
    deinit {
        print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}
