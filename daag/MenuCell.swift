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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var corner: UILabel!
    @IBOutlet weak var calory: UILabel!
    @IBOutlet weak var actualPrice: UILabel!
    
    let formatter = NSNumberFormatter()
    
    static let baseUrl = "http://daag.kr.pe"

    
    private var _menu: Menu?
    var menu: Menu {
        get {
            return _menu!
        }
        set {
            let menu = newValue
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            
            // photo
            if let imageSource = menu.imageSource {
                let url = NSURL(string: MenuTableViewCell.baseUrl + imageSource)
                dispatch_async(dispatch_get_main_queue()){
                    self.photo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "NoImage"))
                }
            }
            // lables
            self.corner.text = menu.corner
            self.title.text = menu.title
            if let calory = menu.calory {
                self.calory.text = String(calory) + "kcal"
            } else {
                self.calory.text = "0"
            }

            if let actualPrice = menu.actualPrice {
                self.actualPrice.text = formatter.stringFromNumber(actualPrice)!
                
            } else {
                self.actualPrice.text = "0"
            }
            
            if menu.soldout! {
                let attributeString = NSMutableAttributedString(string: menu.title!)
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                self.title.attributedText = attributeString
                
                self.corner.text = "판매가 종료되었습니다."
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
