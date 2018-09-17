//
//  InsertItemScreen.swift
//  Faver
//
//  Created by Takumi Nishida on 9/9/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import UIKit

class InsertItemScreen: UIViewController {

    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var doneButton: UIButton!

    
    @IBOutlet weak var labelVar1: UILabel!
    @IBOutlet weak var labelVar2: UILabel!
    @IBOutlet weak var labelVar3: UILabel!
    @IBOutlet weak var labelVar4: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 38, y: 100, width: 250, height: 210)
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 0.1]
        labelVar4.layer.mask = gradient
        */

        // Do any additional setup after loading the view.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToList", sender: self)
    }
    
    @IBAction func textBoxAction(_ sender: Any) {
        labelVar4.text = labelVar3.text
        labelVar3.text = labelVar2.text
        labelVar2.text = labelVar1.text
        labelVar1.text = textBox.text
        textBox.text = ""
    }
    
}

