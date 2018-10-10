//
//  InsertItemScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/9/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class InsertItemScreen: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    @IBOutlet weak var labelVar1: UILabel!
    @IBOutlet weak var labelVar2: UILabel!
    @IBOutlet weak var labelVar3: UILabel!
    @IBOutlet weak var labelVar4: UILabel!
    @IBOutlet weak var useageDateSwitch: UISwitch!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var savedText: String!
    var strArray = [String]()
    var listArray:[List] = []
    var globalNotificationNum = 0
    var inputAmount = 0
    var useByDate = 0
    
    
    struct globalVar {
        static var currentItem = String()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        /*
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 38, y: 100, width: 250, height: 210)
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 0.1]
        labelVar4.layer.mask = gradient
        */

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if sender.isOn == true {
            useByDate = 1
        }
        else {
            useByDate = 0
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
        
            let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context)
            savedText = textField.text
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
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if textField.text != "" {
            
            let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context)
            savedText = textField.text
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
            }
        }
        self.fetchData()
        //print(listArray.count)
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
            let number = 5
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(number), repeats: false)
            let request = UNNotificationRequest(identifier: listArray[item].itemName!, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            //print("\(ship.value) is from \(ship.key)")
        }
        inputAmount = 0
        
        self.performSegue(withIdentifier: "goToList", sender: self)
    }
    
    @IBAction func listButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToList", sender: self)
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
        labelVar4.text = labelVar3.text
        labelVar3.text = labelVar2.text
        labelVar2.text = labelVar1.text
        labelVar1.text = textField.text
        
        textField.text = ""
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
    
}

