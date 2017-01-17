//
//  InicioViewTableViewCell.swift
//  Murmur
//
//  Created by irving fierro on 13/11/16.
//  Copyright © 2016 Murmur. All rights reserved.
//

import UIKit

open class InicioViewTableViewCell: UITableViewCell {
    
    
    @IBOutlet var Murmur: UITextView!
    
    @IBOutlet var MurmurImage: UIImageView!
    
    @IBOutlet var ImageViewHeightConstraint: NSLayoutConstraint!
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    open func configure(_ Murmur:String)
   {
    
     self.Murmur.text = Murmur
    
    }
    
}
