//
//  SwiftNoteNavigationBar.swift
//  Swfitnotes
//
//  Created by John Lago on 1/22/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit

class SwiftNoteNavigationBar: UINavigationBar {
    
    override var layer: CALayer{
        let layer = super.layer
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = CGFloat(2.0)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.darkGray.cgColor
        return layer
    }
}
