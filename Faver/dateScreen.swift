//
//  dateScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 10/10/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit
import CoreData

class dateScreen: UIViewController {

    @IBOutlet weak var saveDate: UIButton!
    @IBOutlet weak var curDate: UIDatePicker!
    
    var curItem: String!
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveDateAction(_ sender: Any) {
        
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "itemName")
        curItem = InsertItemScreen.globalVar.currentItem
        print(curItem)
        userFetch.predicate = NSPredicate(format: "itemName = %@", curItem!)
        //myList.setValue("whole", forKey: "itemMeasure")
        userFetch.setValue(curDate.date, forKey: "shelfLife")
        
        self.performSegue(withIdentifier: "dateToHome", sender: self)
    }
    
}
