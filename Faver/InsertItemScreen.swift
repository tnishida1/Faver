//
//  InsertItemScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/9/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//
import UIKit
import RAMAnimatedTabBarController
import RAMReel
import CoreData
import UserNotifications
import SwiftMessages

class InsertItemScreen: UIViewController, UITextFieldDelegate,
    UICollectionViewDelegate {

    @IBOutlet weak var view2: UIView!
    
    private var datePicker: UIDatePicker?
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myList = NSManagedObject.init()
    var savedText: String!
    var strArray = [String]()
    var listArray:[List] = []
    var globalNotificationNum = 0
    var inputAmount = 0
    var useByDate = 0
    var curDate = Date()
    var popUpInput: String!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationVC = segue.destination as! UINavigationController
        let rootVC = navigationVC.viewControllers.first!
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hide))
        rootVC.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func hide() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var dateUnitsVar: UITextField!
    @IBAction func dateUnits(_ sender: Any) {
    }
    
    @IBOutlet weak var noDateUnitsVar: UITextField!
    @IBAction func noDateUnits(_ sender: Any) {
    }
    
    @IBOutlet weak var dateQuantityVar: UITextField!
    @IBAction func dateQuantity(_ sender: Any) {
    }
    
    @IBOutlet weak var noDateQuantityVar: UITextField!
    @IBAction func noDateQuantity(_ sender: Any) {
    }
    
    @IBOutlet weak var popupDateVar: UIDatePicker!
    @IBAction func popupDate(_ sender: Any) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        
        dataSource = SimplePrefixQueryDataSource(data)
        ramReel = RAMReel(frame: view2.bounds, dataSource: dataSource, placeholder: "Enter an item…", attemptToDodgeKeyboard: false) {
            if $0 != "" {
                print("Plain:", $0)
                
                //new item to enter into DB
                var flag = 0
                
                self.myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: self.context)
                
                if let path = Bundle.main.path(forResource: "item", ofType: "plist") {
                    
                    //If your plist contain root as Array
                    if let root = NSArray(contentsOfFile: path) as? [[String: Any]] {
                        
                        for item in root {
                            if($0.caseInsensitiveCompare((item["name"] as! String)) == .orderedSame) {
                            //if $0 == item["name"] as! String {
                                print($0)
                                self.myList.setValue($0, forKey: "itemName")
                                let time = (Int)(item["dOP_Refrigerate_Min"] as! String)
                                
                                if (item["dOP_Refrigerate_Metric"] as! String) == "Days" {
                                    let today = Date()
                                    let date = Calendar.current.date(byAdding: .day, value: time ?? 0, to: today)
                                    self.myList.setValue(date, forKey: "shelfLife")
                                }
                                else if (item["dOP_Refrigerate_Metric"] as! String) == "Weeks" {
                                    let today = Date()
                                    let date = Calendar.current.date(byAdding: .weekOfMonth, value: time ?? 0, to: today)
                                    self.myList.setValue(date, forKey: "shelfLife")
                                }
                                else if (item["dOP_Refrigerate_Metric"] as! String) == "Months" {
                                    let today = Date()
                                    let date = Calendar.current.date(byAdding: .month, value: time ?? 0, to: today)
                                    self.myList.setValue(date, forKey: "shelfLife")
                                }
                                
                                print(item["dOP_Refrigerate_Metric"] ?? "null")
                                print(item["dOP_Refrigerate_Min"] ?? "empty")
                                flag = 1
                            }
                        }
                    }
                }
                if flag == 0 {
                    let childVC = self.storyboard!.instantiateViewController(withIdentifier: "Popup")
                    //let segue = BottomCardSegue(identifier: nil, source: self, destination: childVC)
                    let segue = SwiftMessagesCenteredSegue(identifier: nil, source: self, destination: childVC)
                    self.prepare(for: segue, sender: nil)
                    segue.perform()
                }
                else {
                    let childVC = self.storyboard!.instantiateViewController(withIdentifier: "PopupNoDate")
                    //let segue = BottomCardSegue(identifier: nil, source: self, destination: childVC)
                    let segue = SwiftMessagesCenteredSegue(identifier: nil, source: self, destination: childVC)
                    self.prepare(for: segue, sender: nil)
                    segue.perform()
                }
            }
        }
        
        ramReel.hooks.append {
            /*
            do {
                try self.context.save()
            }
            catch {
                print(error)
            }*/
            
            //self.fetchData()
            //let content = UNMutableNotificationContent()
            
            //let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: self.context)
            //self.savedText = $0
            
            
            
            /*
             if textField.text != "" {
             
             let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context)
             
             strArray = savedText!.components(separatedBy: " ")
             if strArray.count > 1 && strArray.count < 4
             {
             if strArray.count == 3 { //4 oz peanuts
             myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
             myList.setValue(strArray[1], forKey: "itemMeasure")
             myList.setValue(strArray[2], forKey: "itemName")
             globalVar.currentItem = strArray[2]
             }
             else{ //2 banana
             myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
             myList.setValue("whole", forKey: "itemMeasure")
             myList.setValue(strArray[1], forKey: "itemName")
             globalVar.currentItem = strArray[1]
             }
             globalNotificationNum += 1
             inputAmount+=1
             }
             else {
             print("incorrect input buddy")
             return false;
             }
             }
             else {
             print("incorrect input buddy")
             return false;
             }
             
             do {
             try context.save()
             }
             catch {
             print(error)
             }
             if useByDate == 1
             {
             self.performSegue(withIdentifier: "homeToDate", sender: self)
             }
             return true
 */
            if $0 != "" {
                let r = Array($0.reversed())
                let j = String(r)
                print("Reversed:", j)
            }
        }
        
        
        view2.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /*
    func createNotif(str: String) -> Void {
        
            if textField.text != "" {
                strArray = textField.text!.components(separatedBy: " ")
                if strArray.count > 1 && strArray.count < 4
                {
                    if handleItem(item: textField.text!) == true {
                        do {
                            try context.save()
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            }
            self.fetchData()
            let rangeMin = listArray.count - inputAmount
            let rangeMax = listArray.count - 1
            for item in rangeMin...rangeMax {
                let content = UNMutableNotificationContent()
                
                let itemQ :String = String(listArray[item].itemQuantity)
                content.title = "Your " + listArray[item].itemName! + " is going to spoil soon!"
                content.body = "You have " + itemQ + " " + listArray[item].itemMeasure! + " " + listArray[item].itemName! + " that you have not used yet."
                content.threadIdentifier = "faver"
                content.badge = globalNotificationNum as NSNumber
                
                //let number = arc4random_uniform(10) + 10
                
                //here is where we set the time for the notification
                if listArray[item].shelfLife == nil {
                    let number = 5
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(number), repeats: false)
                    let request = UNNotificationRequest(identifier: listArray[item].itemName!, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                else {
                    let timeInterval = listArray[item].shelfLife?.timeIntervalSinceNow
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval!, repeats: false)
                    let request = UNNotificationRequest(identifier: listArray[item].itemName!, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            inputAmount = 0
            
            self.performSegue(withIdentifier: "goToList", sender: self)
        }
        
    }*/
    
    func handleItem(item: String) -> Bool {
        
        let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context)
        
        
        
        if strArray.count == 3 { //4 oz peanuts
            myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
            myList.setValue(strArray[1], forKey: "itemMeasure")
            myList.setValue(strArray[2], forKey: "itemName")
            globalNotificationNum += 1
            inputAmount+=1
        }
        else{ //2 banana
            myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
            myList.setValue("whole", forKey: "itemMeasure")
            myList.setValue(strArray[1], forKey: "itemName")
            globalNotificationNum += 1
            inputAmount+=1
        }
        if useByDate == 1 {
            myList.setValue(curDate, forKey: "shelfLife")
            print(curDate)
            return true
        }
        else {
            myList.setValue(nil, forKey: "shelfLife")
            //search for date inside database
        }
        return true
    }
    
    /*
    @IBAction func donePressed(_ sender: Any) {
        if textField.text != "" {
            strArray = textField.text!.components(separatedBy: " ")
            if strArray.count > 1 && strArray.count < 4
            {
                if handleItem(item: textField.text!) == true {
                    do {
                        try context.save()
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        self.fetchData()
        let rangeMin = listArray.count - inputAmount
        let rangeMax = listArray.count - 1
        for item in rangeMin...rangeMax {
            let content = UNMutableNotificationContent()
            
            let itemQ :String = String(listArray[item].itemQuantity)
            content.title = "Your " + listArray[item].itemName! + " is going to spoil soon!"
            content.body = "You have " + itemQ + " " + listArray[item].itemMeasure! + " " + listArray[item].itemName! + " that you have not used yet."
            content.threadIdentifier = "faver"
            content.badge = globalNotificationNum as NSNumber

            //let number = arc4random_uniform(10) + 10
            
            //here is where we set the time for the notification
            if listArray[item].shelfLife == nil {
                let number = 5
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(number), repeats: false)
                let request = UNNotificationRequest(identifier: listArray[item].itemName!, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
            else {
                let timeInterval = listArray[item].shelfLife?.timeIntervalSinceNow
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval!, repeats: false)
                let request = UNNotificationRequest(identifier: listArray[item].itemName!, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
        inputAmount = 0
        
        self.performSegue(withIdentifier: "goToList", sender: self)
    }*/
    
    func fetchData(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            listArray = try context.fetch(List.fetchRequest())
        }
        catch {
            print(error)
        }
    }
    
    
    fileprivate let data: [String] = {
        //Property List file name = regions.plist
        let pListFileURL = Bundle.main.url(forResource: "item", withExtension: "plist", subdirectory: "")
        if let pListPath = pListFileURL?.path,
            let pListData = FileManager.default.contents(atPath: pListPath) {
            do {
                let pListObject = try PropertyListSerialization.propertyList(from: pListData, options:PropertyListSerialization.ReadOptions(), format:nil)
                
                //Cast pListObject - If expected data type is Array of Dict
                guard let pListArray = pListObject as? [Dictionary<String, AnyObject>] else {
                    return []
                }
                
                var arrayOfItems = [String]()
                
                for dict in pListArray {
                    //print(dict["name"] as! String)
                    arrayOfItems.append(dict["name"] as! String)
                }
                
                return arrayOfItems
                
            } catch {
                print("Error reading regions plist file: \(error)")
                return []
            }
        }
        return []
    }()
    

}
