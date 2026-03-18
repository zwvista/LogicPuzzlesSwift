//
//  FussyWaiterGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FussyWaiterGameScene: GameScene<FussyWaiterGameState> {
    var gridNode: FussyWaiterGridNode {
        get { getGridNode() as! FussyWaiterGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addFoodDrink(ch: Character, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        guard ch != " " else {return}
        let imageName = switch ch {
        case "a": "hamburger"
        case "b": "pizza"
        case "c": "fries"
        case "d": "donut"
        case "e": "fish"
        case "f": "icecream"
        case "g": "pig"
        case "A": "drink_blue"
        case "B": "cup"
        case "C": "wine_red_glass"
        case "D": "beer_glass"
        case "E": "cocktail"
        case "F": "wine_white_glass"
        case "G": "lemonade_bottle"
        default: ""
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize /  2, height: gridNode.blockSize / 2))
    }
    
    func centerLeftPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.25)) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.25)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func centerRightPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.75)) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.75)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }

    override func levelInitialized(_ game: AnyObject, state: FussyWaiterGameState, skView: SKView) {
        let game = game as! FussyWaiterGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FussyWaiterGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let (point1, point2) = (centerLeftPoint(p: p), centerRightPoint(p: p))
                let nodeNameSuffix = "-\(r)-\(c)"
                let foodNodeName = "food" + nodeNameSuffix
                let drinkNodeName = "drink" + nodeNameSuffix
                let o = game[p]
                addFoodDrink(ch: o.food, s: .normal, point: point1, nodeName: foodNodeName)
                addFoodDrink(ch: o.drink, s: .normal, point: point2, nodeName: drinkNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FussyWaiterGameState, to stateTo: FussyWaiterGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let (point1, point2) = (centerLeftPoint(p: p), centerRightPoint(p: p))
                let nodeNameSuffix = "-\(r)-\(c)"
                let foodNodeName = "food" + nodeNameSuffix
                let drinkNodeName = "drink" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateFood[p], stateTo.pos2stateFood[p])
                let (s3, s4) = (stateFrom.pos2stateDrink[p], stateTo.pos2stateDrink[p])
                if o1.food != o2.food || s1 != s2 {
                    if o1.food != " " { removeNode(withName: foodNodeName) }
                    if o2.food != " " {
                        addFoodDrink(ch: o2.food, s: s2!, point: point1, nodeName: foodNodeName)
                    }
                }
                if o1.drink != o2.drink || s3 != s4 {
                    if o1.drink != " " { removeNode(withName: drinkNodeName) }
                    if o2.drink != " " {
                        addFoodDrink(ch: o2.drink, s: s4!, point: point2, nodeName: drinkNodeName)
                    }
                }
            }
        }
    }
}
