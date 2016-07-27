//
//  EventCell.swift
//  project-18
//
//  Created by Isaac Wang on 7/26/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import Foundation

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}