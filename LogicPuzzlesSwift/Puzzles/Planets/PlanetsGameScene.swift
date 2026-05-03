//
//  PlanetsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PlanetsGameScene: GameScene<PlanetsGameState> {
    var gridNode: PlanetsGridNode {
        get { getGridNode() as! PlanetsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addObject(o: PlanetsObject, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let imageName = switch o {
        case .none: "planet_none"
        case .north: "planet_north"
        case .northEast: "planet_north_east"
        case .northWest: "planet_north_west"
        case .east: "planet_east"
        case .west: "planet_west"
        case .south: "planet_south"
        case .southEast: "planet_south_east"
        case .southWest: "planet_south_west"
        case .sun: "sun"
        case .nebula: "nebula"
        default: "planet_none"
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: PlanetsGameState, skView: SKView) {
        let game = game as! PlanetsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PlanetsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let o = state[p]
                if o != .empty {
                    addObject(o: o, s: state.pos2state[p]!, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: PlanetsGameState, to stateTo: PlanetsGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                switch o2 {
                case .empty:
                    break
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: tileNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                default:
                    addObject(o: o2, s: s2!, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
}
