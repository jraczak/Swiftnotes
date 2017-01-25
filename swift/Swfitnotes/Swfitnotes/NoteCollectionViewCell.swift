//
//  CollectionViewCell.swift
//  Swfitnotes
//
//  Created by John Lago on 1/18/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblNoteTitle: UILabel!
    @IBOutlet weak var lblNoteBody: UILabel!
    @IBOutlet weak var btnNoteStar: UIButton!
    var isStarred: Bool = false{
        didSet {
            btnNoteStar.setImage(UIImage(named: "star_button_\(isStarred)"),for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowRadius = CGFloat(2.0)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.darkGray.cgColor
        //        self.layer.shadowPath = CGPath(rect: self.bounds, transform: nil)
        
    }
    
    @IBAction func tappedStarButton(_ sender: UIButton) {
    }
    
}
