//
//  GardenerGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GardenerGameScene: GameScene<GardenerGameState> {
    var gridNode: GardenerGridNode {
        get {return getGridNode() as! GardenerGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addHint2(p: Position, isHorz: Bool, s: HintState, point: CGPoint) {
        var point = point
        if isHorz {
            point.x += gridNode.blockSize / 2
        } else {
            point.y -= gridNode.blockSize / 2
        }
        let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
        let nodeName = "hint" + nodeNameSuffix
        let hintNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 8)
        hintNode.position = point
        hintNode.name = nodeName
        hintNode.strokeColor = s == .complete ? .green : .red
        hintNode.fillColor = s == .complete ? .green : .red
        hintNode.glowWidth = 4.0
        gridNode.addChild(hintNode)
    }

    override func levelInitialized(_ game: AnyObject, state: GardenerGameState, skView: SKView) {
        let game = game as! GardenerGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: GardenerGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.strokeColor = .yellow
        lineNode.name = "line"
        gridNode.addChild(lineNode)
        
        // addHints
        for (p, (n, _)) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                if case .forbidden = state[p] {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                }
                if state.invalidSpacesHorz.contains(p) {
                    addHint2(p: p, isHorz: true, s: .error, point: point)
                }
                if state.invalidSpacesVert.contains(p) {
                    addHint2(p: p, isHorz: false, s: .error, point: point)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: GardenerGameState, to stateTo: GardenerGameState) {
        for (p, (n, _)) in stateFrom.game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 {
                removeNode(withName: hintNodeName)
                addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
            }
        }
        var trees = Set<Position>()
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let treeNodeName = "tree" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func hintNodeName(isHorz: Bool) -> String {
                    return "hint" + nodeNameSuffix + "-" + (isHorz ? "h" : "v");
                }
                func addTree(s: AllowedObjectState) {
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: treeNodeName)
                }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                if String(describing: o1) != String(describing: o2) {
                    switch o1 {
                    case .forbidden:
                        removeNode(withName: forbiddenNodeName)
                    case .tree:
                        removeNode(withName: treeNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .forbidden:
                        addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                    case let .tree(s):
                        trees.insert(p)
                        addTree(s: s)
                    case .marker:
                        addMarker()
                    default:
                        break
                    }
                }
                let (b1, b2) = (stateFrom.invalidSpacesHorz.contains(p), stateTo.invalidSpacesHorz.contains(p))
                if b1 != b2 {
                    if !b1 {addHint2(p: p, isHorz: true, s: .error, point: point)}
                    if !b2 {removeNode(withName: hintNodeName(isHorz: true))}
                }
                let (b3, b4) = (stateFrom.invalidSpacesVert.contains(p), stateTo.invalidSpacesVert.contains(p))
                if b3 != b4 {
                    if !b3 {addHint2(p: p, isHorz: false, s: .error, point: point)}
                    if !b4 {removeNode(withName: hintNodeName(isHorz: false))}
                }
            }
        }
        for (p, (n, _)) in stateFrom.game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 || trees.contains(p) {
                removeNode(withName: hintNodeName)
                addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
            }
        }
    }
}
