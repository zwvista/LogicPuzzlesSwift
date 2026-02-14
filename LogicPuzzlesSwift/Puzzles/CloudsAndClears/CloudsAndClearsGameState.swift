//
//  CloudsAndClearsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class CloudsAndClearsGameState: GridGameState<CloudsAndClearsGameMove> {
    var game: CloudsAndClearsGame {
        get { getGame() as! CloudsAndClearsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { CloudsAndClearsDocument.sharedInstance }
    var objArray = [CloudsAndClearsObject]()
    var pos2stateHint = [Position: HintState]()
    var pos2stateAllowed = [Position: AllowedObjectState]()
    
    override func copy() -> CloudsAndClearsGameState {
        let v = CloudsAndClearsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: CloudsAndClearsGameState) -> CloudsAndClearsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CloudsAndClearsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<CloudsAndClearsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> CloudsAndClearsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> CloudsAndClearsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout CloudsAndClearsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout CloudsAndClearsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .left
        case .left: .right
        case .right: .horizontal
        case .horizontal: .top
        case .top: .bottom
        case .bottom: .vertical
        case .vertical: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .left : .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 3/Clouds and Clears

        Summary
        Holes in the sky

        Description
        1. Paint the clouds according to the numbers.
        2. Each cloud or empty Sky move contains a single number that is the extension of the region
           itself.
        3. On a region there can be other numbers. These will indicate how many empty (non-cloud) tiles
           around it (diagonal too) including itself.
    */
    private func updateIsSolved() {
        isSolved = true
        var cars = [[Position]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard let n = (CloudsAndClearsGame.car_offset.indices.first { i in
                    let offset = CloudsAndClearsGame.car_offset[i]
                    let obj = CloudsAndClearsGame.car_objects[i]
                    return offset.indices.allSatisfy {
                        let p2 = p + offset[$0]
                        return isValid(p: p2) && self[p2] == obj[$0]
                    }
                }) else {continue}
                let car = CloudsAndClearsGame.car_offset[n].map { p + $0 }
                cars.append(car)
            }
        }
        for car in cars {
            let rng = car.filter { game.pos2hint[$0] != nil }
            guard rng.count == 1 else {
                isSolved = false
                for p in rng { pos2stateHint[p] = .error }
                continue
            }
            let pHint = rng[0]
            let n2 = game.pos2hint[pHint]!
            let isHorz = car[1] - car[0] == Position.East
            let deltaMin = isHorz ? -car[0].col : -car[0].row
            let deltaMax = isHorz ? cols - 1 - car.last!.col : rows - 1 - car.last!.row
            let deltas = (deltaMin...deltaMax).filter { d in
                car.allSatisfy {
                    let p2 = $0 + (isHorz ? Position(0, d) : Position(d, 0))
                    return car.contains(p2) || !self[p2].isCar()
                }
            }
            let n1 = deltas.last! - deltas[0]
            let s: HintState = n1 == n2 ? .complete : .error
            pos2stateHint[pHint] = s
            if s == .error { isSolved = false }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if self[p].isCar() {
                    let s: AllowedObjectState = (cars.contains {
                        $0.contains(p)
                    }) ? .normal : .error
                    pos2stateAllowed[p] = s
                    if s == .error { isSolved = false }
                }
                if game.pos2hint[p] != nil && pos2stateHint[p] == nil {
                    isSolved = false
                    pos2stateHint[p] = .normal
                }
            }
        }
    }
}
