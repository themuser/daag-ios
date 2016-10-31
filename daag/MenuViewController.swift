//
//  MenuTableTableViewController.swift
//  SDS Campus Menu
//
//  Created by Myungkyo Jung on 6/2/15.
//  Copyright (c) 2015 Myungkyo Jung. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import HealthKit
import Toaster
import Timepiece

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var menuList = [Menu]()
    var menuDictionary = [String: [Menu]]()
    
    @IBOutlet weak var menuTableView: UITableView!
    var menus: JSON?

    var selectedMenu: Menu?
    
    var emptyView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView = Bundle.main.loadNibNamed("EmptyMenu", owner: self, options: nil)?[0] as? UIView
        
        menuTableView.reloadData()
        retrieveTodayMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.shakeDetected), name: NSNotification.Name(rawValue: "shake"), object: nil)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.becomeFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "shake"), object: self)
        }
    }
    
    func shakeDetected(){
        // TODO: 음식 랜덤픽
    }
    
    func retrieveTodayMenu(){
        let headers = ["Accept": "application/json"]
        Alamofire.request("http://daag.kr.pe/", headers: headers)
            .responseString(encoding: String.Encoding.utf8,
                completionHandler: { response in
                    
//                    #if DEBUG
//                        let jsonBody = self.json
//                        #elseif RELEASE
                        let jsonBody = response.result.value
//                    #endif
                    
                    if jsonBody == nil {
                        self.menuTableView.backgroundView = self.emptyView
                        self.menuTableView.separatorStyle = .none
                        
                      
                    } else if let data = jsonBody?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        let json = JSON(data: data)
                        
                        if json.count == 0 {
                            self.menuTableView.backgroundView = self.emptyView
                            self.menuTableView.separatorStyle = .none
                        } else {
                            self.menuTableView.backgroundView = nil
                            self.menuTableView.separatorStyle = .singleLine
                            
                            // list presentation
                            for each in json {
                                let menu = Menu(data: each.1)
                                
                                if self.menuDictionary[menu.floor!] == nil {
                                    self.menuDictionary[menu.floor!] = [Menu]()
                                }
                                self.menuDictionary[menu.floor!] = self.menuDictionary[menu.floor!]! + [menu]
                            }
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.menuTableView.reloadData()
                    }
                }
        )
        
    }

    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.menuDictionary.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customHeader = tableView.dequeueReusableCell(withIdentifier: "Header")
        customHeader?.layoutMargins = UIEdgeInsets.zero
        
        let key = Array(menuDictionary.keys)[section]
        let sectionTitleLabel = customHeader?.viewWithTag(10) as! UILabel
        sectionTitleLabel.text = key.uppercased()
        
        return customHeader
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = Array(menuDictionary.keys)[section]
        return key.uppercased()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(menuDictionary.keys)[section]
        let numberOfRows = menuDictionary[key]?.count
        
        return numberOfRows!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MenuTableViewCell?
        let key = Array(menuDictionary.keys)[(indexPath as NSIndexPath).section]
        
        if let menus = menuDictionary[key] {

            let menu = menus[(indexPath as NSIndexPath).row]
            cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuTableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "MenuCell") as? MenuTableViewCell
            }
            cell?.menu = menu
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {
        let key = Array(menuDictionary.keys)[(indexPath as NSIndexPath).section]
        if let menus = menuDictionary[key] {
            let menu = menus[(indexPath as NSIndexPath).row]
            self.selectedMenu = menu
            let eatAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "EAT", handler: {action, indexPath in
                let alertControl = UIAlertController(title: "이 음식을 드시기로 결정하셨나요? 건강앱에 이력이 저장됩니다.", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "예", style: .default, handler: { action in
                    self.addCaloryInformationToHealthKit(self.selectedMenu!)
                    self.menuTableView.reloadData()
                })
                let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: { action in
                    tableView.setEditing(false, animated: true)
                })
                alertControl.addAction(cancelAction)
                alertControl.addAction(okAction)
                self.present(alertControl, animated: true, completion: nil)
            })
            eatAction.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
            return [eatAction]
        }
        
        return nil
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // does nothing but still needs to be here
    }
    
    // MARK: - HealthKit
    func addCaloryInformationToHealthKit(_ menu: Menu){
        if let calory = menu.calory {
            let calories = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)!, quantity: HKQuantity(unit: HKUnit.calorie(), doubleValue: Double(calory) * 1000.0), start: Date(), end: Date())
            let food = HKCorrelation(type: HKCorrelationType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!, start: Date(), end: Date(), objects: NSSet(array: [calories]) as Set<NSObject> as! Set<HKSample>)
            
            let healthKitStore = HKHealthStore()
            healthKitStore.save(food, withCompletion: {(success:Bool, error:NSError!) -> Void in
                if success {
                    let toast = Toast.init(text: "성공적으로 저장되었습니다.", delay: Delay.short, duration: Delay.long)
                    toast.show()
                    
                } else {
                    print(error)
                }
            } as! (Bool, Error?) -> Void)
        }
        
    }
    
    // for test in none-service time
    let json = "[{\"title_kor\":\"비지찌개\",\"title_eng\":\"Pureed Soybean Stew\",\"kcal\":727,\"low_cal\":true,\"soldout\":false,\"price\":5500,\"payments\":2500,\"img_src\":\"/foodcourt/menu?menuId=PROD007647\",\"corner\":\"KOREAN 1\",\"floor\":\"b1\"},{\"title_kor\":\"오징어두루치기&소면&어묵국\",\"title_eng\":\"Spicy Stir-Fried Squid\",\"kcal\":755,\"soldout\":false,\"price\":5500,\"payments\":2500,\"img_src\":\"/foodcourt/menu?menuId=PROD007203\",\"corner\":\"KOREAN 2\",\"floor\":\"b1\"},{\"title_kor\":\"밀양돼지국밥\",\"title_eng\":\"Pork Soup with Rice\",\"kcal\":881,\"high_cal\":true,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD007261\",\"corner\":\"탕맛기픈\",\"floor\":\"b1\"},{\"title_kor\":\"오징어불고기전골\",\"title_eng\":\"Bulgogi and Squid Hot Pot\",\"kcal\":834,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD007E86\",\"corner\":\"탕맛기픈\",\"floor\":\"b1\"},{\"title_kor\":\"냉메밀소바\",\"title_eng\":\"Chilled Buckwheat Noodles\",\"kcal\":798,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD005070\",\"corner\":\"가츠엔\",\"floor\":\"b1\"},{\"title_kor\":\"히레가스\",\"title_eng\":\"Pork Tenderloin Cutlet\",\"kcal\":838,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD005048\",\"corner\":\"가츠엔\",\"floor\":\"b1\"},{\"title_kor\":\"카레라이스&허브오징어튀김\",\"title_eng\":\"curry on the Rice\",\"kcal\":824,\"soldout\":false,\"price\":5500,\"payments\":2500,\"img_src\":\"/foodcourt/menu?menuId=PROD007276\",\"corner\":\"WESTERN\",\"floor\":\"b1\"},{\"title_kor\":\"수제깐풍오므라이스\",\"title_eng\":\"Omelette Rice with chili chicken\",\"kcal\":880,\"high_cal\":true,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD007293\",\"corner\":\"WESTERN\",\"floor\":\"b1\"},{\"title_kor\":\"비지찌개\",\"title_eng\":\"Pureed Soybean Stew\",\"kcal\":727,\"low_cal\":true,\"soldout\":false,\"price\":5500,\"payments\":2500,\"img_src\":\"/foodcourt/menu?menuId=PROD007647\",\"corner\":\"KOREAN 1\",\"floor\":\"b2\"},{\"title_kor\":\"오징어두루치기&소면&어묵국\",\"title_eng\":\"Spicy Stir-Fried Squid\",\"kcal\":755,\"soldout\":false,\"price\":5500,\"payments\":2500,\"img_src\":\"/foodcourt/menu?menuId=PROD007203\",\"corner\":\"KOREAN 2\",\"floor\":\"b2\"},{\"title_kor\":\"미트라자냐\",\"title_eng\":\"Meat Lasagna\",\"kcal\":866,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD003652\",\"corner\":\"Napolipoli\",\"floor\":\"b2\"},{\"title_kor\":\"불고기포테이토피자\",\"title_eng\":\"Beef and Potato Pizza\",\"kcal\":944,\"very_high_cal\":true,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD003771\",\"corner\":\"Napolipoli\",\"floor\":\"b2\"},{\"title_kor\":\"달마크니커리&또띠아칩\",\"title_eng\":\"Dahl Makhani Curry&Tortilla\",\"kcal\":793,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD002171\",\"corner\":\"asian*picks\",\"floor\":\"b2\"},{\"title_kor\":\"분차볶음밥(베트남식볶음밥)\",\"title_eng\":\"Bun Cha Fried Rice\",\"kcal\":870,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD002109\",\"corner\":\"asian*picks\",\"floor\":\"b2\"},{\"title_kor\":\"산채비빔밥\",\"title_eng\":\"Wild Herbs and Vegetable Bibim\",\"kcal\":755,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD007036\",\"corner\":\"고슬고슬비빈\",\"floor\":\"b2\"},{\"title_kor\":\"삼겹살치즈철판비빔밥\",\"title_eng\":\"Pork Belly Bibimbap with Cheese\",\"kcal\":817,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD007K50\",\"corner\":\"고슬고슬비빈\",\"floor\":\"b2\"},{\"title_kor\":\"(쉐프)연어스테이크\",\"title_eng\":\"Chef's Choice\",\"kcal\":545,\"very_low_cal\":true,\"soldout\":true,\"img_src\":\"/foodcourt/menu?menuId=PROD010027\",\"corner\":\"Chef's Counter\",\"floor\":\"b2\"},{\"title_kor\":\"(헬스)저염닭개장\",\"title_eng\":\"health-giving\",\"kcal\":561,\"very_low_cal\":true,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD010026\",\"corner\":\"Chef's Counter\",\"floor\":\"b2\"},{\"title_kor\":\"사천매운자장면\",\"title_eng\":\"Sichuan-style Noodles in Black Soybean Sauce\",\"kcal\":862,\"soldout\":true,\"img_src\":\"/foodcourt/menu?menuId=PROD006005\",\"corner\":\"XingFu China\",\"floor\":\"b2\"},{\"title_kor\":\"짬뽕밥\",\"title_eng\":\"Spicy Seafood Noodle Soup with Rice\",\"kcal\":853,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD006051\",\"corner\":\"XingFu China\",\"floor\":\"b2\"},{\"title_kor\":\"의령메밀소바\",\"title_eng\":\"Chilled Buckwheat Noodles\",\"kcal\":851,\"soldout\":false,\"price\":6000,\"payments\":3500,\"img_src\":\"/foodcourt/menu?menuId=PROD005397\",\"corner\":\"우리미각면\",\"floor\":\"b2\"},{\"title_kor\":\"돼지불고기비빔냉면\",\"title_eng\":\"Mixed Noodles with Pork Bulgogi\",\"kcal\":868,\"soldout\":false,\"price\":6500,\"payments\":4000,\"img_src\":\"/foodcourt/menu?menuId=PROD007O34\",\"corner\":\"우리미각면\",\"floor\":\"b2\"}]" as? String
}
