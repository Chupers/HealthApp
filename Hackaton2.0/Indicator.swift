//
//  Indicator.swift
//  Hackaton2.0
//
//  Created by Eugenie Chupris on 9/11/19.
//  Copyright © 2019 Eugenie Chupris. All rights reserved.
//

import Foundation
import UIKit
class Indicator{
    let NameOfIndicator : String
    let Value : Double?
    let Norms : Double
    let Color : UIColor
    init(NameOfIndicator : String , Value : Double?, Norms : Double,Color : UIColor) {
        self.NameOfIndicator = NameOfIndicator
        self.Norms = Norms
        self.Value = Value
        self.Color = Color
    }
}
