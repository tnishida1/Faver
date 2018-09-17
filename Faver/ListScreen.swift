//
//  ListScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/15/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit

class ListScreen: UIViewController {

    @IBAction func tabBarButtonPress(_ sender: Any) {
        self.performSegue(withIdentifier: "goToHome", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
