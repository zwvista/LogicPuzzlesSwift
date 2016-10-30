//
//  Copyable.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/30.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24242629/implementing-copy-in-swift

protocol Copyable {
    init(instance: Self)
}

extension Copyable {
    func copy() -> Self {
        return Self.init(instance: self)
    }
}
