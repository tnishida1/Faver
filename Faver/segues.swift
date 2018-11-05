//
//  segues.swift
//  Faver
//
//  Created by Takumi Nishida on 11/4/18.
//  Copyright © 2018 Takumi Nishida. All rights reserved.
//

import Foundation
import SwiftMessages

class SwiftMessagesCenteredSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
    }
}
