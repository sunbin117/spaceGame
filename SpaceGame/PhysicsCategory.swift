//
//  PhysicsCategory.swift
//  SpaceGame
//
//  Created by 韩小胜 on 2018/1/24.
//  Copyright © 2018年 sun. All rights reserved.
//

import UIKit

class PhysicsCategory {
    static let Player: UInt32 = 0x1 << 0
    static let Enemy: UInt32 = 0x1 << 1
    static let Energy: UInt32 = 0x1 << 2
    static let EnmyBorder: UInt32 = 0x1 << 3
    static let PlayerBorder: UInt32 = 0x1 << 4
}
