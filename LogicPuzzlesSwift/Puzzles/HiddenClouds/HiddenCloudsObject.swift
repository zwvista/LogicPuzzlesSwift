//
//  HiddenCloudsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum HiddenCloudsObject {
    case empty
    case marker
    case forbidden
    case cloud(state: AllowedObjectState = .normal)
    init() {
        self = .empty
    }
    func toString() -> String {
        switch self {
        case .cloud:
            return "cloud"
        case .marker:
            return "marker"
        case .forbidden:
            return "forbidden"
        default:
            return "empty"
        }
    }
    static func fromString(str: String) -> HiddenCloudsObject {
        switch str {
        case "cloud":
            return .cloud()
        case "marker":
            return .marker
        default:
            return .empty
        }
    }
}

struct HiddenCloudsGameMove {
    var p = Position()
    var obj = HiddenCloudsObject()
}
