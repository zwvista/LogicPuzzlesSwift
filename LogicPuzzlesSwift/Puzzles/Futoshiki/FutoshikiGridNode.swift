//
//  FutoshikiGridNode.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

// http://stackoverflow.com/questions/33464925/draw-a-grid-with-spritekit

class FutoshikiGridNode: GridNode {
    convenience init(blockSize: CGFloat, rows: Int, cols: Int) {
        let texture = GridNode.gridTexture(blockSize: blockSize, rows: rows, cols: cols, verticalLinesRange: 1...1, horizontalLinesRange: 1...1)
        self.init(texture: texture, color: .clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
}
