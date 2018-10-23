//
//  InsertItemScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/9/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//
import UIKit
import RAMReel
import CoreData
import UserNotifications

extension String {
    var isNumeric : Bool {
        get {
            return Double(self) != nil
        }
    }
}

class InsertItemScreen: UIViewController, UITextFieldDelegate, UICollectionViewDelegate {

    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    @IBOutlet weak var labelVar1: UILabel!
    @IBOutlet weak var labelVar2: UILabel!
    @IBOutlet weak var labelVar3: UILabel!
    @IBOutlet weak var labelVar4: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = dateSelector
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(InsertItemScreen.dateChanged(datePicker:)), for: .valueChanged)
        
        
        //error.layer.opacity = 0
        //textField.delegate = self
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
        
        dataSource = SimplePrefixQueryDataSource(data)
        
        ramReel = RAMReel(frame: view2.bounds, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: false) {
            print("Plain:", $0)
        }
        
        ramReel.hooks.append {
            let r = Array($0.reversed())
            let j = String(r)
            print("Reversed:", j)
        }
        
        
        
        view2.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        if textField.text != "" {
            strArray = textField.text!.components(separatedBy: " ")
            if (strArray.count > 1) && (strArray.count < 4) && (strArray[0].isNumeric) {
                if handleItem(item: textField.text!) == true {
                    do {
                        try context.save()
                    }
                    catch {
                        print(error)
                    }
                    return true
                }
            }
            else {
                issueError()
                return false
            }
        }
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
    
    fileprivate let data: [String] = {
        do {
            guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
                return []
            }
            
            let data = try WordReader(filepath: dataPath)
            return data.words
        }
        catch let error {
            print(error)
            return []
        }
    }()
    
}
