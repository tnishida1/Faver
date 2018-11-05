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

extension String {
    var isNumeric : Bool {
        get {
            return Double(self) != nil
        }
    }
}

class InsertItemScreen: UIViewController, UITextFieldDelegate,
    UICollectionViewDelegate {

    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var useageDateSwitch: UISwitch!
    @IBOutlet weak var dateSelector: UIDatePicker!
    @IBOutlet weak var error: UITextView!
    
    private var datePicker: UIDatePicker?
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = dateSelector
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(InsertItemScreen.dateChanged(datePicker:)), for: .valueChanged)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        
        dataSource = SimplePrefixQueryDataSource(data)
        ramReel = RAMReel(frame: view2.bounds, dataSource: dataSource, placeholder: "Enter an item…", attemptToDodgeKeyboard: false) {
            print("Plain:", $0)
            
            let childVC = self.storyboard!.instantiateViewController(withIdentifier: "Popup")
            //let segue = BottomCardSegue(identifier: nil, source: self, destination: childVC)
            let segue = SwiftMessagesCenteredSegue(identifier: nil, source: self, destination: childVC)
            self.prepare(for: segue, sender: nil)
            segue.perform()
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
            
            let r = Array($0.reversed())
            let j = String(r)
            print("Reversed:", j)
        }
        
        
        view2.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
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
        
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        curDate = datePicker.date
        view.endEditing(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if sender.isOn == true {
            useByDate = 1
            dateSelector.isEnabled = true
            dateSelector.isHidden = false
        }
        else {
            useByDate = 0
            dateSelector.isEnabled = false
            dateSelector.isHidden = true
        }
    }
    
    func issueError() {
        error.layer.opacity = 1
        UIView.animate(withDuration: 1, animations: {
            self.error.layer.opacity = 0
        })
    }
    
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

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return false
    }
    
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
    }
    
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
