//
//  GroupModel.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/09/30.
//

import UIKit

struct GroupModel: Codable {
    let id: Int
    let name: String
    let categoryId: Int
    let questionCnt: Int
}
