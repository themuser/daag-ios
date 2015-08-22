//
//  MenuTableViewCell.swift
//  SDS Campus Menu
//
//  Created by Myungkyo Jung on 6/5/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var corner: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var calory: UILabel!
//    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var actualPrice: UILabel!
    
    let formatter = NSNumberFormatter()
    
    static let baseUrl = "http://daag.kr.pe"

    
    private var _menu: Menu?
    var menu: Menu {
        get {
            return _menu!
        }
        set {
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            
            // photo
            if let imageSource = newValue.imageSource {
                let url = NSURL(string: MenuTableViewCell.baseUrl + imageSource)
                dispatch_async(dispatch_get_main_queue()){
                    self.photo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "NoImage"))
                }
            }
            // lables
            self.corner.text = newValue.corner
            self.title.text = newValue.title
            if let calory = newValue.calory {
                self.calory.text = String(calory) + "kcal"
            } else {
                self.calory.text = "0"
            }
//            if let price = newValue.price {
//
//                let attributeString = NSMutableAttributedString(string: formatter.stringFromNumber(price)!)
//                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//                self.price.attributedText = attributeString
//                
//            } else {
//                self.price.text = "0"
//            }
            if let actualPrice = newValue.actualPrice {
                self.actualPrice.text = formatter.stringFromNumber(actualPrice)!
                
            } else {
                self.actualPrice.text = "?"
            }
        }
    }
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
