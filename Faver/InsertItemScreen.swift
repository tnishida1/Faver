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
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var savedText: String!
    var strArray = [String]()
    var listArray:[List] = []
    var globalNotificationNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        /*
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 38, y: 100, width: 250, height: 210)
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 0.1]
        labelVar4.layer.mask = gradient
        */

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
        
            let myList = NSEntityDescription.insertNewObject(forEntityName: "List", into: context)
            savedText = textField.text
            strArray = savedText!.components(separatedBy: " ")
            if strArray.count > 1 && strArray.count < 4
            {
                var item: String!
                var quantity: String!
                
                if strArray.count == 3 { //4 oz peanuts
                    myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
                    myList.setValue(strArray[1], forKey: "itemMeasure")
                    myList.setValue(strArray[2], forKey: "itemName")
                    item = strArray[2]
                    quantity = strArray[0] + " " + strArray[1]
                }
                else{ //2 banana
                    myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
                    myList.setValue("whole", forKey: "itemMeasure")
                    myList.setValue(strArray[1], forKey: "itemName")
                    item = strArray[1]
                    quantity = strArray[0] + " whole"
                }
                
                let lastItem = listArray[listArray.endIndex]
                
                let content = UNMutableNotificationContent()
                content.title = "Your " + lastItem.itemName! + " is going to spoil soon!"
                content.body = "You have " + quantity + item + "that you have not used yet."
                globalNotificationNum += 1
                content.badge = globalNotificationNum as NSNumber
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
        return true
    }
    
    @IBAction func donePressed(_ sender: Any) {
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
    
}

