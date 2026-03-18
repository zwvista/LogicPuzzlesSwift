//
//  FussyWaiterObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

struct FussyWaiterObject {
    var food: Character = " "
    var drink: Character = " "
    var str: String { "\(food)\(drink)" }
}

struct FussyWaiterGameMove {
    var p = Position()
    var obj: Character = " "
    var isDrink: Bool { obj.isUppercase }
}
