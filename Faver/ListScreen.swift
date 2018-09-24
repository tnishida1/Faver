//
//  ListScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/15/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit
import CoreData

class ListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listTable: UITableView!
    
    var listArray:[List] = []
    
    @IBAction func tabBarButtonPress(_ sender: Any) {
        self.performSegue(withIdentifier: "goToHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.delegate = self
        listTable.dataSource = self
        
        self.fetchData()
        self.listTable.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let name = listArray[indexPath.row]
        print(name.itemName? + " " + name.itemMeasure?)
        cell.textLabel?.text = name.itemName? + " " + name.itemMeasure?
        return cell
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
