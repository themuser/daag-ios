//
//  MenuTableViewCell.swift
//  SDS Campus Menu
//
//  Created by Myungkyo Jung on 6/5/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import UIKit
import SDWebImage

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var corner: UILabel!
    @IBOutlet weak var calory: UILabel!
    @IBOutlet weak var actualPrice: UILabel!
    
    let formatter = NumberFormatter()
    
    static let baseUrl = "http://daag.kr.pe"

    
    fileprivate var _menu: Menu?
    var menu: Menu {
        get {
            return _menu!
        }
        set {
            let menu = newValue
            formatter.numberStyle = NumberFormatter.Style.decimal
            
            // photo
            if let imageSource = menu.imageSource {
                let url = URL(string: MenuTableViewCell.baseUrl + imageSource)
                DispatchQueue.main.async{
                    self.photo.sd_setImage(with: url, placeholderImage: UIImage(named: "NoImage"))
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
                
                self.actualPrice.text = formatter.string(from: NSNumber(value:actualPrice))!
                
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
