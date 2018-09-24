//
//  InsertItemScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/9/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit
import CoreData

class InsertItemScreen: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var labelVar1: UILabel!
    @IBOutlet weak var labelVar2: UILabel!
    @IBOutlet weak var labelVar3: UILabel!
    @IBOutlet weak var labelVar4: UILabel!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var savedText: String?
    var strArray = [String]()
    
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
            strArray = savedText?.components(separatedBy: " ")
            dump(strArray)
            if strArray.count == 3 { //4 oz peanuts
                myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
                myList.setValue(strArray[1], forKey: "itemMeasure")
                myList.setValue(strArray[2], forKey: "itemName")
            }
            else if strArray.count == 2 { //2 banana
                myList.setValue(Int(strArray[0]), forKey: "itemQuantity")
                myList.setValue("whole", forKey: "itemMeasure")
                myList.setValue(strArray[1], forKey: "itemName")
            }
            else {
                print("incorrect input buddy")
                return false;
            }
            
            if myList.hasChanges == true {
                print("yes")
            }
            else {
                print("no")
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
    
    @IBAction func textFieldAction(_ sender: Any) {
        labelVar4.text = labelVar3.text
        labelVar3.text = labelVar2.text
        labelVar2.text = labelVar1.text
        labelVar1.text = textField.text
        
        textField.text = ""
    }
    
}

