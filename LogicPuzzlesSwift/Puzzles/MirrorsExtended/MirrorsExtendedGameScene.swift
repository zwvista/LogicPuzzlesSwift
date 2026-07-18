//
//  MirrorsExtendedGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MirrorsExtendedGameScene: GameScene<MirrorsExtendedGameState> {
    var gridNode: MirrorsExtendedGridNode {
        get { getGridNode() as! MirrorsExtendedGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, ch: Character, n: Int, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: "\(ch)\(n)", fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: hintNodeName)
    }
    
    func addLines(game: MirrorsExtendedGame) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
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
        lineNode.name = "line"
        gridNode.addChild(lineNode)
    }

    override func levelInitialized(_ game: AnyObject, state: MirrorsExtendedGameState, skView: SKView) {
        let game = game as! MirrorsExtendedGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MirrorsExtendedGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        addLines(game: game)

        // add Hints
        for (ch, o) in game.letter2laser {
            for o2 in o.dots {
                addHint(p: o2.p, ch: ch, n: o.number, s: state.letter2state[ch]!)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MirrorsExtendedGameState, to stateTo: MirrorsExtendedGameState) {
        let game = stateFrom.game
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for (ch, o) in game.letter2laser {
            for o2 in o.dots {
                let (s1, s2) = (stateFrom.letter2state[ch]!, stateTo.letter2state[ch]!)
                guard s1 != s2 else {continue}
                removeHint(p: o2.p)
                addHint(p: o2.p, ch: ch, n: o.number, s: s2)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                func addSlash(p1: Position, p2: Position) {
                    let pathToDraw = CGMutablePath()
                    pathToDraw.move(to: gridNode.cornerPoint(p: p1))
                    pathToDraw.addLine(to: gridNode.cornerPoint(p: p2))
                    let slashNode = SKShapeNode(path:pathToDraw)
                    slashNode.strokeColor = .green
                    slashNode.lineWidth = 4
                    slashNode.name = tileNodeName
                    gridNode.addChild(slashNode)
                }
                switch o2 {
                case .forbidden:
                    addDotMarker2(color: .red, point: point, nodeName: tileNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                case .backward:
                    addSlash(p1: p, p2: p + MirrorsExtendedGame.offset3[3])
                case .forward:
                    addSlash(p1: p + MirrorsExtendedGame.offset3[1], p2: p + MirrorsExtendedGame.offset3[2])
                default:
                    break
                }
            }
        }

        removeNode(withName: "line")
        addLines(game: game)
    }
}
