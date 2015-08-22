//
//  Menu.swift
//  SDS Campus Menu
//
//  Created by Myungkyo Jung on 7/5/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import Foundation
import SwiftyJSON

class Menu: Printable {
    var floor: String?
    var imageSource: String?
    var corner: String?
    var title: String?
    var calory: Int?
    var price: Int?
    var actualPrice: Int?
 
    
    init(data: JSON){
        floor = data["floor"].string
        imageSource = data["img_src"].string
        corner = data["corner"].string
        title = data["title_kor"].string
        calory = data["kcal"].int
        price = data["price"].int
        actualPrice = data["payments"].int
        
    }
    
    
    var description: String {
        return "floor: \(floor), imageSource: \(imageSource), corner: \(corner), title: \(title), calory: \(calory), price: \(price), actualPrice: \(actualPrice)"
    }
}