//
//  PlanetsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PlanetsGameState: GridGameState<PlanetsGameMove> {
    var game: PlanetsGame {
        get { getGame() as! PlanetsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PlanetsDocument.sharedInstance }
    var objArray = [PlanetsObject]()
    var pos2state = [Position: AllowedObjectState]()
    
    override func copy() -> PlanetsGameState {
        let v = PlanetsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PlanetsGameState) -> PlanetsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PlanetsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> PlanetsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PlanetsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout PlanetsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty && self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout PlanetsGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p) && game[p] == .empty else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .sun
        case .sun: .nebula
        case .nebula: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .sun : .empty
        default: o
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 1/Planets

        Summary
        Planets, Stars and Nebulas

        Description
        1. In Planets you are given an interesting Galaxy, where Suns only
           shine their light in horizontal and vertical lines.
        2. On the board you can see the Planets of this Galaxy. Each Planet
           is lit on some side (or not lit at all).
        3. You should place one Sun on each row and column, according to how
           the Planets are lit.
        4. You should also place one Nebula on each row and column.
        5. Nebulas block sunlight, so if there is a Nebula between a Sun and
           a Planet, the Planet won't be lit.
        6. Finally, Planets block sunlight too. So if there is a Planet
           between a Sun and another Planet, the further Planet won't be lit
           by that Sun.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2state[p] = .normal
                if self[p] == .forbidden {
                    self[p] = .empty
                }
            }
        }
        func checkSymbols(suns: [Position], nebulae: [Position], empties: [Position]) {
            // 3. You should place one Sun on each row and column, according to how
            //    the Planets are lit.
            if suns.count != 1 {
                isSolved = false
                for p in suns { pos2state[p] = .error }
            }
            // 4. You should also place one Nebula on each row and column.
            if nebulae.count != 1 {
                isSolved = false
                for p in nebulae { pos2state[p] = .error }
            }
            if allowedObjectsOnly && !suns.isEmpty && !nebulae.isEmpty {
                for p in empties { self[p] = .forbidden }
            }
        }
        for r in 0..<rows {
            var suns = [Position]()
            var nebulae = [Position]()
            var empties = [Position]()
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .sun:
                    suns.append(p)
                case .nebula:
                    nebulae.append(p)
                case .empty, .marker:
                    empties.append(p)
                default:
                    break
                }
            }
            checkSymbols(suns: suns, nebulae: nebulae, empties: empties)
        }
        for c in 0..<cols {
            var suns = [Position]()
            var nebulae = [Position]()
            var empties = [Position]()
            for r in 0..<rows {
                let p = Position(r, c)
                switch self[p] {
                case .sun:
                    suns.append(p)
                case .nebula:
                    nebulae.append(p)
                case .empty, .marker:
                    empties.append(p)
                default:
                    break
                }
            }
            checkSymbols(suns: suns, nebulae: nebulae, empties: empties)
        }
        // 3. You should place one Sun on each row and column, according to how
        //    the Planets are lit.
        // 5. Nebulas block sunlight, so if there is a Nebula between a Sun and
        //    a Planet, the Planet won't be lit.
        // 6. Finally, Planets block sunlight too. So if there is a Planet
        //    between a Sun and another Planet, the further Planet won't be lit
        //    by that Sun.
        for p in game.planets {
            let o = self[p]
            var isLit = [Int]()
            for i in 0..<4 {
                let os = PlanetsGame.offset[i]
                var p2 = p + os
                while isValid(p: p2) {
                    let o2 = self[p2]
                    if o2 == .sun {
                        isLit.append(i); break
                    }
                    if o2 != .empty, o2 != .marker {break}
                    p2 += os
                }
            }
            if PlanetsGame.isLitDict[isLit] != o {
                isSolved = false
                pos2state[p] = .error
            }
        }
    }
}
